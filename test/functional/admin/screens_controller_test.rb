require 'test_helper'

class Admin::ScreensControllerTest < ActionController::TestCase

  context "listing" do
    setup { get :index }
    should_respond_with :success
    should_render_template :index
    should_assign_to :screens, :equals => 'Screen.all'
  end
  
  context "adding" do
    context "showing form" do
      setup { get :new }
      should_respond_with :success
      should_render_template :new
      should_assign_to :screen, :class => Screen
    end
    
    context "adding records" do
      setup { get :create, :screen => { :id => 1, :name => "first", :api_key => "key" }}
      should_redirect_to "admin_screens_url"
      should_set_the_flash_to /created/
      should "create record" do
        sc = Screen.find(1)
        assert_equal "first", sc.name
        assert_equal "key", sc.api_key
      end
    end
    
    context "adding duplicate record" do
      setup do
        sc = Screen.new
        sc.id = 1
        sc.save!
        get :create, :screen => { :id => 1, :name => "first", :api_key => "key" }
      end
      should_render_template :new
    end
  end
  
  context "editing" do
    context "showing form" do
      setup { get :edit, :id => screens(:first) }
      should_respond_with :success
      should_render_template :edit
      should_assign_to :screen, :class => Screen
    end
    
    context "updating records" do
      setup { get :update, :id => screens(:first), :screen => { :name => "a", :api_key => "b" }}
      should_redirect_to "admin_screens_url"
      should_set_the_flash_to /updated/
      should "update db" do
        sc = screens(:first)
        sc.reload
        assert_equal "a", sc.name
        assert_equal "b", sc.api_key
      end
    end
  end
  
  context "deleting" do
    setup { get :destroy, :id => screens(:first) }
    should_redirect_to "admin_screens_url"
    should_set_the_flash_to /deleted/
  end

end
