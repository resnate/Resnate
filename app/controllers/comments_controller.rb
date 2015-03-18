class CommentsController < ApplicationController

  def create
  	if params[:commentable_type] == "activity"
      @commentable = PublicActivity::Activity.find(params[:commentable_id])       
    elsif params[:commentable_type] == "review"
  		@commentable = Review.find(params[:commentable_id])
  	end
    @get = "/activity/" + params[:commentable_id] + "/comments/"
    @comment = Comment.build_from( @commentable, current_user.id, params[:body] )
    @comment.save
    Pusher.trigger('comments', 'comment', {:message => @get})
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

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
  end

end
