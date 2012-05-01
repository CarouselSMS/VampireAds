class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
	t.column :phone_num,		:integer,	:limit => 10,	:null => false
	t.column :body,			:string,	:limit => 160,	:null => false
	t.column :created_at,		:datetime
	t.column :was_displayed,	:boolean,				:null => false
    end
  end

  def self.down
    drop_table :messages
  end
end
