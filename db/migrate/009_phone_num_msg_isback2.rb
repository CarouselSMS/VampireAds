class PhoneNumMsgIsback2 < ActiveRecord::Migration
  def self.up
	change_column :messages , :phone_num, :string
  end

  def self.down
  end
end
