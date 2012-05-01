class MessagesController < ApplicationController
	
	layout nil
	
	require 'uri'
	require 'cgi'
	
	after_filter :set_charset
	
	NUMBER_ON_SCREEN  = 3

  DEFAULT_STORENAME = "STORE"

  MSG_WELCOME       = "Thanks for registering! You can now chat by txting your msg to us. Txt HELP for more. Subscribe to special offers from [STORENAME] by txting SUB. Your ID: [ID]"
  MSG_SUBSCRIBE     = "Subscribed to [STORENAME] special offers. Up to 5/mo. Std msging rates & other charges may apply. Cancel, reply STOP, for help, HELP. T&Cs: VampireAds.com"""
  MSG_HELP          = "[STORENAME] offers subscription. Up to 5 msgs/mo. Visit VampireAds.com for assistance. Other/std charges may apply. Reply STOP to unsubscribe."
  MSG_UNSUBSCRIBE   = "You've canceled your subscription to [STORENAME] special offers. You will not receive any more messages. More, visit VampireAds.com."
                    
  CMD_SUBSCRIBE     = "vampire"
  CMD_HELP          = "help"
  CMD_UNSUBSCRIBE   = "stop"

  ALL_COMMANDS      = [ CMD_SUBSCRIBE, CMD_HELP, CMD_UNSUBSCRIBE ]

	def smartlist
		@total_users = User.find(:all).size
		@msgs = Message.find(:all, :include => :user, :order => "messages.created_at DESC")
	end

	def capa_report
		@msgs = Message.find(:all, :include => :user, :order => "users.created_at DESC", :conditions=>"on_list = true")
		@msgs.inject([]) { |@users,msg| @users << msg.user }
		@users.uniq!
	end
	
	def signup_list
		@signup_users = User.find_all_by_on_list(true, :include => :messages, :order => "users.created_at DESC")
	end

	def blacklist
		user = Message.find(params[:id]).user
		
		if user.blacklisted?
			flash[:notice] = "user #{user.phone_num} has already been blacklisted."
		else
			user.blacklisted = true
			if user.save!
				flash[:notice] = "user #{user.phone_num} has been blacklisted."
			else
				flash[:notice] = "blacklisting failed for user #{user.phone_num}."
			end
		end
		redirect_to :action => 'smartlist'
	end
	
	def unblacklist
		user = Message.find(params[:id]).user
		
		if !user.blacklisted?
			flash[:notice] = "user #{user.phone_num} isn't currently blacklisted."
		else
			user.blacklisted = false
			if user.save!
				flash[:notice] = "user #{user.phone_num} has been unblacklisted."
			else
				flash[:notice] = "unblacklisting failsed for user #{user.phone_num}."
			end
		end
		redirect_to :action => 'smartlist'
	end

	def new
		@message = Message.new
	end
	
	def create
		@user = User.find_by_name("no associated user")
		@message = Message.new(params[:message])
		@message.displayed = true
		if @message.save!
			@user.messages << @message
			@user.save!
			flash[:notice] = 'Message was successfully created.'
			redirect_to :action => 'smartlist'
		else
			render :action => 'new'
		end
	end
	
	def send_to_flash
    conditions = { "users.blacklisted" => false, :displayed => true }
    conditions[:screen_id] = (params[:screen] || "1").to_i
    
		msgs = Message.find(:all, :order => "messages.created_at DESC", :limit => NUMBER_ON_SCREEN, :joins => :user, :conditions => conditions)
		
    # Get text messages
    text = ""
    3.times do |i|
      m, c = msgs[i], 3 - i
      body, phone_num, recipient = (m && m.body_enc), (m && m.user.phone_num_w1), (m && m.recipient && m.recipient.seq_num)
      text += "&msg#{c}=#{body}&phone_number#{c}=#{phone_num}&recipient#{c}=#{recipient}&status=DONE."
    end
    
		render :text =>	text + "&num_sent=#{Message.count(:joins => :user, :conditions => conditions)}"
	end
	
	def set_charset
		headers["Content-Type"] = "text/html; charset=utf-8" 
	end

  # -----------------------------------------------------------------------------------------------

  # Invoked by the service layer
  def service_layer_callback
    if params[:type]
      case params[:type]
      when 'incoming_message'
        process_incoming_message 
      when 'session_closed'
        process_session_closed
      else
        render :text => ""
      end
    else
      render :text => ""
    end
  end

  # -----------------------------------------------------------------------------------------------
	# @deprecated Old Version
  # -----------------------------------------------------------------------------------------------
  
	# Invoked when the message from the service layer arrives.
	def receive
		phone_num = params[:phone_num][/\d{10}$/]
		
		msg = Message.create(:body => CGI.unescape(URI.unescape(params[:body])), :displayed => true)
		
		user   = User.find_by_phone_num(phone_num)
		user ||= User.new(:phone_num => phone_num)
		user.messages << msg
		
		client_keyword = 'vampire'
		
		case msg.body.downcase
			when client_keyword
				user.on_list 	= true
				msg.displayed = false
				eval("send_#{client_keyword}_optin(#{phone_num})")
			when "stop"
				user.on_list	= false
				msg.displayed = false
				eval("send_#{client_keyword}_stop(#{phone_num})")
		end
		
		if user.new_record?
			eval("send_#{client_keyword}_welcome(#{phone_num})")
		end
		
		msg.save!
		user.save!
		
		render :text => "phone#:#{user.phone_num} body:#{msg.body}"
	end		
	
	def send_vampire_optin(mt_num)
		sendsms(mt_num, MSG_SUBSCRIBE)
	end
	
	def send_vampire_stop(mt_num)
		sendsms(mt_num, MSG_UNSUBSCRIBE)
	end
	
	def send_vampire_welcome(mt_num)
		sendsms(mt_num, MSG_WELCOME)
	end
		
	def sendsms(mt_num, body)
		username = 'pbomber'
		password = 'sexybitch'
		
		body_formatted = URI.escape(body, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
		
		mt_num = mt_num.to_i
		
		http = Net::HTTP.new('localhost', 13013)
		http.use_ssl = true
		http.start do |http|
			http.get "/cgi-bin/sendsms?user=#{username}&pass=#{password}&to=%2B1#{mt_num}&text=#{body_formatted}"
		end
	end
	
	private
	
	# Invoked when the session between the phone and the app is closed on the service layer side.
	def process_session_closed
    phone_nums = params[:phone_numbers].split(",")
    
    # Expire the user if it exists to start new dialog later
    users = User.update_all("updated_at = NULL", { :phone_num => phone_nums })
    
    render :text => ""
  end
  
  
	# Invoked when a messages from the service layer arrives.
	def process_incoming_message
	  response  = ""
	  sid       = (params[:screen] || "1").to_i
    screen    = Screen.find_or_create_by_id(sid)
	  phone_num = params[:phone_number]
	  body      = params[:body]
	  
	  if phone_num && body
  	  displayed = true
  	  user      = User.find_or_initialize_by_phone_num(:phone_num => phone_num, :on_list => false)

      if user.new_record? || user.update_expired_seq_num
        # New record or new session
        user.save!
        displayed = false
        response  = MSG_WELCOME.gsub('[ID]', user.seq_num.to_s)
        
        # This is an unusual case, but we cover it as it may appear in debugging / demoing.
        # Usually the first thing we see from new phones is the Keyword.
        response  = "" if ALL_COMMANDS.include?(body.downcase.strip)
      else
        case body.downcase
        when CMD_SUBSCRIBE
          user.update_attribute(:on_list, true)
          displayed = false
          response  = MSG_SUBSCRIBE
        when CMD_HELP
          displayed = false
          response  = MSG_HELP if user.on_list
        when CMD_UNSUBSCRIBE
          displayed = false
          if user.on_list
            user.update_attribute(:on_list, false)
            response  = MSG_UNSUBSCRIBE
          end
        else
          # Normal message
          if Message::personal?(body)
            recipient = Message::recipient(body)
            if recipient.nil?
              displayed = false
            else
              body = Message::textual_body(body)
              send_message(recipient.phone_num, "#{user.seq_num}: #{body}", screen)
            end
          end
        end
      end

  	  message = Message.create(:body => body, :user => user, :displayed => displayed, :screen => screen, :recipient => recipient)

  	  logger.error("Saving of the message errored: #{message.errors.inspect}") if message.new_record?
	  end
	  
	  render :text => set_storename(response, screen.name)
  end
  
	# Replaces the [STORENAME] pattern with the actual store name
	def set_storename(text, storename)
	  return text if text.blank?
	  return text.gsub(/\[storename\]/i, storename || "UNKNOWN")
  end
	
  # Sends a text to the recipient through service layer.
  def send_message(phone_number, body, screen)
    # Can't send messages from unknown screens
    return if screen.nil? || screen.api_key.blank?
    
    url = SERVICE_LAYER_API_URL + "/send_message"
    data = {
      :api_key          => screen.api_key,
      :phone_number     => phone_number,
      :body             => body
    }
    
    Net::HTTP.post_form(URI.parse(url), data)
  rescue => e
    logger.error "Sending message errored: #{e}"
  end
end
