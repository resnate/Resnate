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
      @like = Like.where(liker_id: @user.id, likeable_type: "Song").find_by_likeable_id(@song.id)
      @like.create_activity :create, owner: @user
      @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Like", trackable_id: @like.id).first.id
      @message = @activity.to_s + ',' + @user.uid.to_s
      Pusher.trigger('activities', 'feed', {:message => @message})
    end
  end

  def destroy
    @user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    @likeable_type = params[:likeable_type]
    if @likeable_type = "Song"

      @content = Song.find(params[:likeable_id]).content
      @songs = Song.where(content: (@content))

      @songs.each do |song|
        if @user.likes?(song)
          @like = Like.where(likeable_type: "Song", likeable_id: song.id).first
          @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Like", trackable_id: @like.id).first
          @activity.destroy
          @user.unlike!(song)
        end
      end

    end
  end

  def show
    @like =  Like.find(params[:id])
  end

  def ifLike
    content = Song.find(params[:likeable_id])
    songs = Song.where(content: params[:content])
    songs.each do |song|
      if @user.likes?(song)
        @count = 1
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