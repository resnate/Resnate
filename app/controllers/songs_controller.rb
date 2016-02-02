class SongsController < ApplicationController

  def create
  	@song = current_user.songs.build(song_params)
    @song.save
    @song.create_activity :create, owner: current_user
    @activity = PublicActivity::Activity.where(trackable_type: "Song", trackable_id: @song.id).first.id.to_s
    @message = @activity + ',' + current_user.uid.to_s
    Pusher.trigger('activities', 'feed', {:message => @message})
    render :layout => false
  end

  def destroy
    @song = Song.find(params[:id])
    @song.destroy
    PublicActivity::Activity.where(trackable_type: "Song", trackable_id: @song.id).first.destroy
      render :layout => false
  end

  def show
      @user = current_user
      @songs = Song.where(content: params[:content])
      
      render :layout => false
    end

  def lastSong
    @song = Song.where(content: params[:content], user_id: current_user.id).first
    render :layout => false
  end

  def history
    @user = User.find(params[:user])
    @songs = @user.songs
      
    render :layout => false
  end

  def like
      @song = Song.find(params[:id])
      current_user.like!(@song)
      @like = Like.where(likeable_type: "Song", likeable_id: params[:id], liker_id: current_user.id).first
      @like.create_activity :create, owner: current_user
      @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Like", trackable_id: @like.id).first.id
      @message = @activity.to_s + ',' + current_user.uid.to_s
      Pusher.trigger('activities', 'feed', {:message => @message})
      render :layout => false
    end

    def unlike
      content = Song.find(params[:id]).content
      @songs = Song.where(content: (content))
      @songs.each do |song|
        current_user.unlike!(song)
      end
      render :layout => false
    end
    
  private

    def song_params
      params.require(:song).permit(:content, :name)
    end
end