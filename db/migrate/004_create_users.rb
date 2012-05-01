class CreateUsers < ActiveRecord::Migration
def self.up
	create_table :users do |t|
		t.column :blacklisted,		:boolean,	:default => false
		t.column :superuser,		:boolean,	:default => false
		t.column :name,			:string
		t.column :phone_num,		:integer
		t.column :created_at,		:timestamp
	end
	
	remove_column :messages, :phone_num
	remove_column :messages, :superuser
	remove_column :messages, :blacklisted
	add_column	:messages, :user_id, :integer
end

  def self.down
    drop_table :users
  end
end
