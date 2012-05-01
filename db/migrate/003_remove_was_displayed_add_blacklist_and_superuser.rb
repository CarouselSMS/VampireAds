class RemoveWasDisplayedAddBlacklistAndSuperuser < ActiveRecord::Migration
  def self.up
	remove_column :messages, :was_displayed
	add_column :messages, :superuser, :boolean
	add_column :messages, :blacklisted, :boolean
  end

  def self.down
  end
end
