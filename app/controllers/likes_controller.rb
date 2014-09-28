class LikesController < ApplicationController
	def show
      @user = User.find(params[:user])
      @likes = Like.where(liker_id: @user.id, likeable_type: "Song")
      render :layout => false
    end
end
