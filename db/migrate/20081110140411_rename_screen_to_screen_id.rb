class RenameScreenToScreenId < ActiveRecord::Migration
  def self.up
    rename_column :messages, :screen, :screen_id
    add_index     :messages, :screen_id
  end

  def self.down
    remove_index  :messages, :screen_id
    rename_column :messages, :screen_id, :screen
  end
end
