class Message < ActiveRecord::Base
	
	belongs_to :user
	belongs_to :recipient, :class_name => "User", :foreign_key => "recipient_id"
	belongs_to :screen
	
	validates_presence_of :screen_id
	validates_presence_of :body
	
	def body_enc
		require 'cgi'
		CGI::escape body
	end
	
	# Returns TRUE if the message is addressed to someone
	def self.personal?(body)
	  /^\s*@\d+(\s|$)/ =~ body
  end
  
  # Returns the textual body of the message free from the recipient tag.
  def self.textual_body(body)
    body.scan(/^\s*(@\d+\s+)?(.*)$/).flatten.last.strip
  end
  
  # Returns the recipient of the message or #nil# if expired or simply not found.
  def self.recipient(body)
    seq_num = body.scan(/^\s*@(\d+)(\s|$)/).flatten.first
    User.unexpired.find_by_seq_num(seq_num)
  end
  
end
