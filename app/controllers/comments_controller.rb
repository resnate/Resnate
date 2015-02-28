class CommentsController < ApplicationController

  def create
  	if params[:commentable_type] == "activity"
      	@commentable = PublicActivity::Activity.find(params[:commentable_id])
        @get = "/activity/" + params[:commentable_id] + "/comments/"
    elsif params[:commentable_type] == "review"
  		@commentable = Review.find(params[:commentable_id])
  	end
    @comment = Comment.build_from( @commentable, current_user.id, params[:body] )
    @comment.save
   
  	render :layout => false
  end

  def index
  	if params[:commentable_type] == "activity"
  		@comments = PublicActivity::Activity.find(params[:commentable_id]).comment_threads
  	elsif params[:commentable_type] == "review"
  		@comments = Review.find(params[:commentable_id]).comment_threads
  	end
  	render :layout => false
  end

end
