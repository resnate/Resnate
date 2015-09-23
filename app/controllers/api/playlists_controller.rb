class API::PlaylistsController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_filter :restrict_access, :except => :userSearch

  def show
    @playlist = Playlist.find(params[:id])
  end

  def update
    current_user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    @playlist = Playlist.find(params[:id])
    @content = params[:content]
    @name = params[:name]
    @description = params[:description]

    if current_user.id == @playlist.user_id
      if @name.present?
        @playlist.update_attributes(name: @name)
      elsif @description.present?
        @playlist.update_attributes(description: @description)
      elsif @content.present?
        @playlist.update_attributes(content: @content)
      end
    end
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