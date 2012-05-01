class MsgIsdisplayed < ActiveRecord::Migration
  def self.up
	add_column :messages, :displayed, :boolean
  end

  def self.down
  end
end
