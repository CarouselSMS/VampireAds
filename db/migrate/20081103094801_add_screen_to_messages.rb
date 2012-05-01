class AddScreenToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :screen, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :messages, :screen
  end
end
