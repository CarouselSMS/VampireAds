class User < ActiveRecord::Base
	has_many :messages

  # Period after which, users without any activity considered to be expired
  EXPIRY_PERIOD = 12.hours
	
	# Unexpired sessions
	named_scope :unexpired, :conditions => [ "updated_at > ?", EXPIRY_PERIOD.ago ]

  before_create :assign_seq_num
	
	def pp_phone_num
		num = self.phone_num
		return "(#{num[0..2]}) #{num[3..5]} - #{num[6..9]}"
	end
	
	def phone_num_w1
		case name
		when "no associated user"
			require 'cgi'
			CGI::escape "from console"
		else
			"1#{phone_num}"
		end	
	end

  # Sees if the session has expired and updates the
  # seq num.
  def update_expired_seq_num
    return false unless expired?

    update_attribute(:seq_num, next_seq_num)
    update_attribute(:updated_at, Time.now)

    true
  end
  
  private
  
  # If session is expired, returns TRUE
  def expired?
    return false if new_record?
    updated_at.nil? || updated_at < EXPIRY_PERIOD.ago
  end
  
  # Return the next sequence number among unexpired users.
  def next_seq_num
    (User.unexpired.map { |u| u.seq_num || 0 }.max || 0)+ 1
  end
  
  # Assigns new sequence number before saving the record
  def assign_seq_num
    self.seq_num = next_seq_num
  end
  
end
