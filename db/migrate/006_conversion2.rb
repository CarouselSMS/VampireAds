class Conversion2 < ActiveRecord::Migration
 def self.up
	change_column :messages , :phone_num, :string
	change_column :users , :phone_num, :string
  end

  def self.down
	change_column :messages , :phone_num, :integer
	change_column :users , :phone_num, :integer
  end
end
