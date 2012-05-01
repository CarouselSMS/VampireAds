class EraseMsgsPhonenum < ActiveRecord::Migration
  def self.up
	remove_column :messages, :phone_num
  end

  def self.down
  end
end
