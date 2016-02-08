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

    render :layout => false
  end

    def unfollow
      @playlist = Playlist.find(params[:playlist])
      @follow = Follow.where(followable_id: @playlist.id, followable_type: "Playlist", follower_id: current_user.id).first
      @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Follow", trackable_id: @follow.id).first
      unless @activity.nil?
        @activity.destroy
      end
      current_user.unfollow!(@playlist)
      user = User.find(@playlist.user_id)
      if current_user != user
        lv1 = user.level
        user.subtract_points(5)
        lv2 = user.level
        if lv1 != lv2
          @user.rm_badge(lv1)
        end
      end
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
