class PlaylistsController < ApplicationController
	def create
  	@playlist = current_user.playlists.build(playlist_params)
    @playlist.save
    @playlist.create_activity :create, owner: current_user
    @activity = PublicActivity::Activity.where(trackable_type: "Playlist", trackable_id: @playlist.id).first.id
    @message = @activity.to_s + ',' + current_user.uid.to_s
    Pusher.trigger('activities', 'feed', {:message => @message})
  end

    def edit
      @playlist = current_user.playlists.find(params[:id])
    end

    def update
      @playlist = Playlist.find(params[:id])
      @content = params[:content]
      @name = params[:name]
      @description = params[:description]
      unless current_user.id != @playlist.user_id
        if @name.present?
          @playlist.update_attributes(name: @name)
        elsif @description.present?
          @playlist.update_attributes(description: @description)
        elsif @content.present?
          @playlist.update_attributes(content: @content)
        end
      end
    end

    def show
      
      @playlist = Playlist.find(params[:id])
      respond_to do |format|
        format.html { render :layout => false }
        format.json
      end
    end


  def destroy

    
    @playlist = Playlist.find(params[:id])
    if @playlist.user_id == current_user.id
      @playlist.destroy
      PublicActivity::Activity.where(trackable_type: "Playlist", trackable_id: @playlist.id).first.destroy
    end
      render :layout => false
  end

  def playlistLi
    @playlist = Playlist.find(params[:id])
    render :layout => false
  end

  def follow
    @playlist = Playlist.find(params[:playlist])
    @user = User.find(@playlist.user_id)
    current_user.follow!(@playlist)
      
    @follow = Follow.where(follower_id: current_user.id, followable_type: "Playlist").find_by_followable_id(@playlist.id)
    @follow.create_activity :create, owner: current_user
    @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Follow", trackable_id: @follow.id).first.id
    @message = @activity.to_s + ',' + current_user.uid.to_s
    Pusher.trigger('activities', 'feed', {:message => @message})
    render :layout => false
  end

    def unfollow
      @playlist = Playlist.find(params[:playlist])
      @user = User.find(@playlist.user_id)
      @follow = Follow.where(followable_id: @playlist.id, followable_type: "Playlist").first
      @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Follow", trackable_id: @follow.id).first
      @activity.destroy
      current_user.unfollow!(@playlist)
      
      render :layout => false
    end

    def playlistFollowers
      @playlist = Playlist.find(params[:id])
      @followers = @playlist.followers(User)
      @playlists = Playlist.all
      render :layout => false
    end

    def newPlaylist
      render :layout => false
    end

  private


    def playlist_params
      params.require(:playlist).permit(:content, :name, :user_id, :description)
    end



end
