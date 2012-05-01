require File.dirname(__FILE__) + '/../test_helper'

class MessageTest < Test::Unit::TestCase

  should_belong_to :user
  should_belong_to :recipient
  should_belong_to :screen
  
  should_require_attributes :screen_id, :body
  
  context "checking if message is personal" do
    should "return true if it is" do
      assert Message::personal?("@12 message")
      assert Message::personal?(" @2 message")
    end
    should "return false if it's not" do
      assert !Message::personal?("1 message")
      assert !Message::personal?("message")
    end
  end
  
  context "finding the recipient" do
    should "return an unexpired recipient" do
      user = users(:unexpired)
      assert_equal user, Message::recipient("@#{user.seq_num} message")
    end
    should "return nil for expired recipient" do
      user = users(:expired)
      assert_nil Message::recipient("@#{user.seq_num} message")
    end
    should "return nil for missing recipient" do
      assert_nil Message::recipient("@0 message")
    end
  end
  
  context "returning the body without recipient info" do
    should "return message without recipient as-is" do
      assert_equal "message", Message::textual_body("message")
    end
    should "strip recipient info" do
      assert_equal "message", Message::textual_body("@1 message")
      assert_equal "message", Message::textual_body(" @12  message ")
    end
  end
end
