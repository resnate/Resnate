class API::UsersController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
before_filter :restrict_access, :except => :userSearch
  def index
    @users = User.all
  end

  def show
    unless User.find_by_uid(params[:id]).nil?
  	 @user = User.find_by_uid(params[:id])
    else 
      @user = nil
    end
  end

  def userSearch
    @profile = JSON.parse(Net::HTTP.get_response(URI.parse("https://graph.facebook.com/me?access_token=" + params[:oauth] + "&appsecret_proof=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, FACEBOOK_CONFIG['secret'], params[:oauth]))).body.html_safe)["id"]
    if User.find_by_uid(@profile).nil?
      @profile = nil
    else
      id = User.find_by_uid(@profile).id
      @access_token = APIKey.find_by_user_id(id).access_token
      @name = User.find(id).name
    end
  end

  def level
    user = User.find(params[:id])
    @points = user.points
    @level = user.level
    @level_name = user.level_name
    @badges = user.badges
  end

private
      def restrict_access
        authenticate_or_request_with_http_token do |token, options|
          APIKey.exists?(access_token: token)
        end

        def request_http_token_authentication(realm = "Application")  
          self.headers["WWW-Authenticate"] = %(Token realm="#{realm.gsub(/"/, "")}")
          self.__send__ :render, :json => { :error => "HTTP Token: Access denied. You did not provide an valid API key." }.to_json, :status => :unauthorized
        end
      end
end