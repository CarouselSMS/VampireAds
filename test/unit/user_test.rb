require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

  context "creation" do
    should "assign unused seq_num" do
      user = User.create!
      assert users(:unexpired).seq_num + 1, user.seq_num
    end
  end

  context "expiry checks" do
    should "return true for an expired user" do
      assert users(:expired).send(:expired?)
    end
    should "return false for an unexpired user" do
      assert !users(:unexpired).send(:expired?)
    end
    should "return false for a new user" do
      assert !User.new.send(:expired?)
    end
  end
  
  context "updating seq_num" do
    should "not update if not expired" do
      user        = users(:unexpired)
      old_seq_num = user.seq_num

      assert       !user.update_expired_seq_num
      assert_equal old_seq_num, user.seq_num
    end

    should "update expired seq num" do
      user        = users(:expired)
      old_seq_num = user.seq_num
      nxt_seq_num = User.unexpired.map { |u| u.seq_num || 0 }.max + 1

      assert       user.update_expired_seq_num
      assert_equal nxt_seq_num, user.seq_num
      assert_equal Date.today, user.updated_at.to_date
    end
    
    should "update expired seq num to the same" do
      user        = users(:expired)
      old_seq_num = user.seq_num
      nxt_seq_num = User.unexpired.map { |u| u.seq_num || 0 }.max + 1
      
      # Set the same seq num before the update
      User.update_all("seq_num = #{nxt_seq_num}, updated_at = null", "id = #{user.id}")
      
      assert       user.update_expired_seq_num
      assert_equal nxt_seq_num, user.seq_num
      assert_equal Date.today, user.updated_at.to_date
    end
  end

end
