class AddNoAssociatedUser < ActiveRecord::Migration
  def self.up
    user = User.find_by_name("no associated user")
    User.create!(:name => "no associated user", :phone_num => "no associated user")
  end

  def self.down
  end
end
