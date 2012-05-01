class AddOnlist < ActiveRecord::Migration
  def self.up
	add_column :users, :on_list, :boolean
  end

  def self.down
  end
end
