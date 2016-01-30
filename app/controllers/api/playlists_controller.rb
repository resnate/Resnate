class API::PlaylistsController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_filter :restrict_access, :except => :userSearch

  def create
    current_user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    @playlist = current_user.playlists.build(playlist_params)
    @playlist.save
    @playlist.create_activity :create, owner: current_user
    @activity = PublicActivity::Activity.where(trackable_type: "Playlist", trackable_id: @playlist.id).first.id
    @message = @activity.to_s + ',' + current_user.uid.to_s
    Pusher.trigger('activities', 'feed', {:message => @message})
    render nothing: true
  end

  def show
    @playlist = Playlist.find(params[:id])
  end

  def followers
    @followers = Playlist.find(params[:id]).followers(User)
    @count = @followers.count
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

  def firstFollowedPlaylist
    current_user = User.find(params[:id])
    unless Follow.where(follower_id: current_user.id, followable_type: "Playlist").count == 0
      @firstFollowedPlaylist = Playlist.find(Follow.where(follower_id: current_user.id, followable_type: "Playlist").first.followable_id)
    end
  end

  def followedPlaylists
    current_user = User.find(params[:id])
    @followedPlaylists = []
    unless Follow.where(follower_id: current_user.id, followable_type: "Playlist").count == 0
      Follow.where(follower_id: current_user.id, followable_type: "Playlist").each do |fP|
        playlist = Playlist.find(fP.followable_id)
        @followedPlaylists.push(playlist)
      end
    end
  end

  def ifFollow
    current_user = User.find(params[:user_id])
    if current_user.follows?(Playlist.find(params[:playlist_id]))
      @follows = true
    else
      @follows = false
    end
  end

  def follow
    @playlist = Playlist.find(params[:playlist])
    current_user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    current_user.follow!(@playlist)
      
    @follow = Follow.where(follower_id: current_user.id, followable_type: "Playlist").find_by_followable_id(@playlist.id)
    @follow.create_activity :create, owner: current_user
    @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Follow", trackable_id: @follow.id).first.id
    @message = @activity.to_s + ',' + current_user.uid.to_s
    Pusher.trigger('activities', 'feed', {:message => @message})
    @user = User.find(@playlist.user_id)
    if current_user != @user
      lv1 = @user.level
      @user.add_points(5)
      current_user.send_message(@user, " is now following " + @playlist.name, "P|" + @playlist.id.to_s)
      Pusher.trigger('messages', 'inbox', { message: @user.id, sender: current_user })
      lv2 = @user.level
      if lv1 != lv2
        User.find(3).send_message(@user, "New level: " + @user.level_name, "B|"+ @user.level_name)
        @user.create_activity key: 'badge.create', parameters: {level: @user.level}, owner: @user
        @user.add_badge(@user.level)
        activity = PublicActivity::Activity.where(key: "badge.create", owner: @user).last.id 
        @message = activity.to_s + ',' + current_user.uid.to_s
        Pusher.trigger('activities', 'feed', {:message => @message})
      end
    end
  end

  def unfollow
    @playlist = Playlist.find(params[:playlist])
    current_user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    @follow = Follow.where(followable_id: @playlist.id, followable_type: "Playlist", follower_id: current_user.id).first
    @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Follow", trackable_id: @follow.id).first
    unless @activity.nil?
      @activity.destroy
    end
    current_user.unfollow!(@playlist)
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

    def playlist_params
      params.require(:playlist).permit(:content, :name, :user_id, :description)
    end
end