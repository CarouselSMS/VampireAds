class Admin::ScreensController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  # Lists all screens
  def index
    @screens = Screen.paginate :page => params[:page], :per_page => 20, :order => "id"
  end
  
  # Shows new screen form
  def new
    @screen = Screen.new
  end
  
  # Creates a screen record
  def create
    @screen = Screen.new(params[:screen])
    @screen.id = params[:screen][:id]
    if @screen.save
      flash[:notice] = "Screen created"
      redirect_to admin_screens_url
    else
      render :action => :new
    end
  end
  
  # Edits a screen
  def edit
    @screen = Screen.find(params[:id])
  end
  
  # Updates a screen
  def update
    @screen = Screen.find(params[:id])
    if @screen.update_attributes(params[:screen])
      flash[:notice] = "Screen updated"
      redirect_to admin_screens_url
    else
      render :action => :edit
    end
  end
  
  # Deletes a screen
  def destroy
    @screen = Screen.find(params[:id])
    @screen.destroy
    
    flash[:notice] = "Screen deleted"
    redirect_to admin_screens_url
  end
  
  private
  
  # Invoked when screen is not found
  def not_found
    redirect_to admin_screens_url
  end
end
