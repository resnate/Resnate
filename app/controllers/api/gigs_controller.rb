class API::GigsController < ApplicationController
    include ActionController::HttpAuthentication::Token::ControllerMethods
  before_filter :restrict_access

  def show
    @gig = Gig.find(params[:id])
  end

  def friendsGoing
    user = User.find(params[:user])
    @friendsArray = []
    unless user.followees(User).count == 0
    user.followees(User).each do |friend|
        if  Gig.where(user_id: friend.id, songkick_id: params[:songkick_id].to_s ).present?
          @friendsArray.push( { "id" => friend.id } )
        end
      end
    end
    render :json => @friendsArray.to_json
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