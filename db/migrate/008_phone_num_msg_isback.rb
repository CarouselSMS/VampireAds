class PhoneNumMsgIsback < ActiveRecord::Migration
  def self.up
	add_column :messages, :phone_num, :string
  end

  def self.down
  end
end
