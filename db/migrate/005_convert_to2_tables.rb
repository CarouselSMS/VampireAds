class ConvertTo2Tables < ActiveRecord::Migration
  def self.up
	add_column :messages, :phone_num, :integer, :limit => 10
  end

  def self.down
  end
end
