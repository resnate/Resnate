class API::SongsController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
	#before_filter :restrict_access, :except => :userSearch

  def create
    current_user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    @song = current_user.songs.build(song_params)
    @song.save
    @songID = @song.id
    @song.create_activity :create, owner: current_user
    @activity = PublicActivity::Activity.where(trackable_type: "Song", trackable_id: @song.id).first.id.to_s
    @message = @activity + ',' + current_user.uid.to_s
    Pusher.trigger('activities', 'feed', {:message => @message})
  end

  def destroy
    @song = Song.find(params[:id])
    @song.destroy
    PublicActivity::Activity.where(trackable_type: "Song", trackable_id: @song.id).first.destroy
  end

	def show
		@song = Song.find(params[:id])
	end

  def findSong
    songs = Song.where(content: params[:content], user_id: params[:user])
    if songs.count > 0
      @songID = songs.first.id
    end
  end

	private

    def song_params
      params.require(:song).permit(:content, :name)
    end
    
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