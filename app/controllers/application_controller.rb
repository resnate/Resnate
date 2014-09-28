class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

before_filter :beforeFilter
before_action :set_device_type

  def beforeFilter
     $request = request
  end 

  include PublicActivity::StoreController


  

  
  	def current_user
    	@current_user ||= User.find(session[:user_id]) if session[:user_id]
  	end
    hide_action :current_user
  	
 helper_method :current_user

 private
  def set_device_type
    request.variant = :phone if browser.mobile?
    request.variant = :tablet if browser.tablet?
  end

end
