class SongsController < ApplicationController

  def create
  	@song = current_user.songs.build(song_params)
    if @song.save
      
      redirect_to root_url
    else
      redirect_to root_url
    end
  end

  def destroy
  end

  def show
      @user = User.find(params[:user])
      @songs = @user.songs.where(content: (params[:content]))
      
      render :layout => false
    end

    def history
      @user = User.find(params[:user])
      @songs = @user.songs
      
      render :layout => false
    end

  def like
      @song = Song.find_by_content(params[:content])
      current_user.like!(@song)
      render :layout => false
    end

    def unlike
      @user = User.find(params[:user])
      @songs = Song.where(content: (params[:content]))
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