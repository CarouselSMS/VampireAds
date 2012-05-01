require File.dirname(__FILE__) + '/../test_helper'

class MessagesControllerTest < ActionController::TestCase

  context "showing index" do
    setup do
      @messages = Message.all(:order => "created_at desc")
      get :smartlist
    end
    should_respond_with :success
    should_assign_to :msgs, :class => Array, :equals => '@messages'
    should_assign_to :total_users, :equals => 'User.count'
  end
  
  context "showing new message page" do
    setup { get :new }
    should_render_template :new
    should_respond_with :success
  end
  
  context "creating message" do
    setup do
      @old_count = Message.count
      post :create, :message => { :body => "test" }
    end
    should "increment message count" do
      assert_equal @old_count + 1, Message.count
    end
    should_redirect_to "smartlist_url"
  end
  
  context "receiving a message" do
    context "default screen" do
      setup do
        receive(users(:on_list), "message")
        @msg = Message.last
      end
      should "create a record in db" do
        assert_equal "message", @msg.body
      end
      should "assign to the screen 0" do
        assert_equal 1, @msg.screen_id
      end
      should "have this screen created" do
        assert_not_nil @msg.screen
      end
    end
    
    context "specific screen" do
      setup do
        @sid = 500
        receive(users(:on_list), "message", @sid)
        @msg = Message.last
      end
      should "create a record in db" do
        assert_equal "message", @msg.body
      end
      should "assign to screen @sid" do
        assert_equal @sid, @msg.screen_id
      end
      should "have this screen created" do
        assert_not_nil @msg.screen
      end
    end
  end
  
  context "closing the session" do
    context "closing ongoing session" do
      setup do
        @user = users(:first)
        @res  = session_closed(@user)
      end
      should_respond_with :success
      should "expire user session" do
        @user.reload
        assert_nil @user.updated_at
      end
      should "respond with a welcome message on the next texting" do
        receive(@user, "keyword")
        @user.reload
        msg = msg(MessagesController::MSG_WELCOME).gsub('[ID]', @user.seq_num.to_s)
        assert_equal msg, @response.body
      end
    end
    
    context "closing non-existent session" do
      setup do
        @res  = session_closed("1000000000")
      end
      should_respond_with :success
    end
  end
  
  context "commands processing" do
    context "HELP" do
      context "for subscribed" do
        setup { receive(users(:on_list), "HELP") }
        should_respond_with :success
        should "return the help message" do
          assert_equal msg(MessagesController::MSG_HELP), @response.body
        end
      end
    end
    
    context "STOP" do
      context "for new phones" do
        setup { receive(1231231231, "STOP") }
        should_respond_with :success
        should "return nothing (silently)" do
          assert_equal "", @response.body
        end
      end

      context "for unsubscribed phones" do
        setup { receive(users(:first), "STOP") }
        should_respond_with :success
        should "return nothing (silently)" do
          assert_equal "", @response.body
        end
      end

      context "with being subscribed" do
        setup { receive(users(:on_list), "STOP") }
        should_respond_with :success
        should "return the unsubscribed message" do
          assert_equal msg(MessagesController::MSG_UNSUBSCRIBE), @response.body
        end
      end
    end
  end

  context "restoring a session after hours of inactivity" do
    setup do
      @expired = users(:expired)
      @old_seq_num = @expired.seq_num
      receive(@expired, "some message")
      @expired.reload
    end
    should "assign new seq_num" do
      assert_equal users(:unexpired).seq_num + 1, @expired.seq_num
    end
    should "return the welcome message" do
      msg = msg(MessagesController::MSG_WELCOME).gsub('[ID]', @expired.seq_num.to_s)
      assert_equal msg, @response.body
    end
  end

  
  context "sending a message to the wall" do
    should "leave message recipient_id nil" do
      receive(users(:unexpired), "wall message")
      assert_nil Message.find_by_body("wall message").recipient
    end
  end
  
  
  context "sending a personal message" do
    context "to existing and not expired user" do
      setup do
        src   = users(:unexpired)
        @dest = users(:first)

        @controller.expects(:send_message).with(@dest.phone_num, "#{src.seq_num}: personal message", Screen.find_or_create_by_id(1))

        receive(src, "@#{@dest.seq_num} personal message")
        @msg  = Message.last
      end
      should "remove '@NN ' from body" do
        assert_equal "personal message", @msg.body
      end
      should "associate message with the recipient" do
        assert_equal @dest, @msg.recipient
      end
    end

    context "to a missing user" do
      setup do
        @body = "@0 message"
        receive(users(:unexpired), @body)
        @msg  = Message.last
      end
      should "record a message but not show on the wall" do
        assert !@msg.displayed
      end
      should "not touch its body" do
        assert_equal @body, @msg.body
      end
      should "not associate any recipient" do
        assert_nil @msg.recipient
      end
    end
  end


  context "sending messages to flash" do
    context "default screen" do
      setup do
        # Leave only two messages
        Message.delete_all
        Message.create!(:body => "wall", :user => users(:first), :created_at => 1.minute.ago, :displayed => true, :screen_id => 1)
        Message.create!(:body => "personal", :user => users(:unexpired), :recipient => users(:first), :displayed => true, :screen_id => 1)

        get :send_to_flash
        @res = @response.body.split('&')
      end
      should "return wall message" do
        assert @res.include?("msg2=wall")
        assert @res.include?("phone_number2=1#{users(:first).phone_num}")
        assert @res.include?("recipient2=")
      end
      should "return personal message" do
        assert @res.include?("msg3=personal")
        assert @res.include?("phone_number3=1#{users(:unexpired).phone_num}")
        assert @res.include?("recipient3=#{users(:first).seq_num}")
      end
    end

    context "chosen screen" do
      setup do
        # Leave only two messages
        Message.delete_all
        Message.create!(:body => "wall", :user => users(:first), :created_at => 1.minute.ago, :displayed => true, :screen_id => 0)
        Message.create!(:body => "personal", :user => users(:unexpired), :recipient => users(:first), :displayed => true, :screen_id => 1)

        get :send_to_flash, :screen => 1
        @res = @response.body.split('&')
      end
      should "return personal message" do
        assert @res.include?("msg3=personal")
        assert @res.include?("phone_number3=1#{users(:unexpired).phone_num}")
        assert @res.include?("recipient3=#{users(:first).seq_num}")
      end
      should "not return a message from a different screen" do
        2.times do |i|
          [ "msg", "phone_number", "recipient" ].each do |msg|
            assert @res.include?(msg + "#{i + 1}=")
          end
        end
      end
    end
  end
  
  # Prepares the message for checking.
  def msg(message, screen = Screen.new(:name => "UNKNOWN"))
    @controller.send(:set_storename, message, screen.name)
  end

  # Simulates the session closed callback
  def session_closed(phone)
    phone_number = phone.kind_of?(User) ? phone.phone_num : phone.to_s
    get :service_layer_callback, :type => "session_closed", :phone_numbers => phone_number
  end
  
  # Simulates the incoming message
  def receive(phone, body, screen = nil)
    phone_number = phone.kind_of?(User) ? phone.phone_num : phone.to_s
    get :service_layer_callback, :type => "incoming_message", :phone_number => phone_number, :body => body, :sent_at => Time.now.to_i, :screen => screen
  end
end
