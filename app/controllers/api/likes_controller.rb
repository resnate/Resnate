class API::LikesController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_filter :restrict_access

  def create
    @user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    @likeable_type = params[:likeable_type]
    @likeable_id = params[:likeable_id]
    if @likeable_type = "Song"
      @song = Song.find(@likeable_id)
      @user.like!(@song)
    end
  end

  def show
    @like =  Like.find(params[:id])
  end

  def ifLike
    @count = Like.where(likeable_type: params[:likeable_type], liker_id: params[:liker_id], likeable_id: params[:likeable_id]).count
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