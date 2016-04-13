class LikesController < ApplicationController
	def show
      @user = User.find(params[:user])
      @likes = Like.where(liker_id: @user.id, likeable_type: "Song")
      @firstLike = Song.find(Like.where(liker_id: @user.id, likeable_type: "Song").first.likeable_id).content
      render :layout => false
    end

    def create
    	render nothing: true
    end
end
