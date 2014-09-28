class PlaylistsController < ApplicationController
	def create
  	@playlist = current_user.playlists.build(playlist_params)
    if @playlist.save
      
      redirect_to root_url
    else
      redirect_to root_url
    end
  end

    def edit
      @playlist = current_user.playlists.find(params[:id])
    end

    def update
    @playlist = current_user.playlists.find(params[:id])
    if @playlist.update_attributes(playlist_params)
      
      redirect_to :root
    else
      redirect_to :root
    end   
    end

  def form
    @playlist = current_user.playlists.find(params[:id])
    render :layout => false
    end

    def show
      
      @playlist = Playlist.find(params[:id])
      render :layout => false
    end


  def destroy

    
    @playlist = Playlist.find(params[:id])
    @playlist.destroy
      render :layout => false
  end

  def follow
      @playlist = Playlist.find(params[:playlist])
      current_user.follow!(@playlist)
      render :layout => false
    end

    def unfollow
      @playlist = Playlist.find(params[:playlist])
      current_user.unfollow!(@playlist)
      render :layout => false
    end

    def playlistFollowers
      @playlist = Playlist.find(params[:id])
      @followers = @playlist.followers(User)
      @playlists = Playlist.all
      render :layout => false
    end

  private


    def playlist_params
      params.require(:playlist).permit(:content, :name)
    end



end
