class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

before_action :detect_device_format

  include PublicActivity::StoreController


  

  
  	def current_user
    	@current_user ||= User.find(session[:user_id]) if session[:user_id]
  	end
    hide_action :current_user
  	
 helper_method :current_user

  private

    def detect_device_format
      case request.user_agent
      when /iPad/i
        request.variant = :tablet
      when /iPhone/i
        request.variant = :phone
      when /Android/i && /mobile/i
        request.variant = :phone
      when /Android/i
        request.variant = :tablet
      when /Windows Phone/i
        request.variant = :phone
      end
    end

end
