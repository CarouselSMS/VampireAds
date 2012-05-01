class AddSeqNumToUsers < ActiveRecord::Migration
  def self.up
    add_column  :users, :seq_num, :integer
    add_index   :users, :seq_num
  end

  def self.down
    remove_index  :users, :seq_num
    remove_column :users, :seq_num
  end
end
