class CommentsController < ApplicationController

  def create
    recipients = []
    if params[:commentable_type] == "activity"
      @commentable = PublicActivity::Activity.find(params[:commentable_id]) 
      recipient = User.find(@commentable.owner_id)
      if @commentable.trackable_type == "Song"    
        notification = "C|S"
      elsif @commentable.trackable_type == "Playlist"    
        notification = "C|P"
      elsif @commentable.trackable_type == "Gig"    
        notification = "C|G"
      end
    elsif params[:commentable_type] == "review"
      @commentable = Review.find(params[:commentable_id])
      recipient = User.find(@commentable.user_id)
      notification = "C|R"
    end

    recipients.push(recipient)

    @get = "/activity/" + params[:commentable_id] + "/comments/"
    @comment = Comment.build_from( @commentable, current_user.id, params[:body] )
    @comment.save
    Pusher.trigger('comments', 'comment', {:message => @get})

    Comment.where(commentable_id: @comment.id).each do |c|
      if c.user_id != @commentable.owner_id && c.user_id != current_user.id
        recipients.push(User.find(c.user_id))
      end
    end

    current_user.send_message(recipients, params[:body], notification)
    recipients.each do |r|
      Pusher.trigger('messages', 'inbox', { message: r.id, sender: @sender})
    end
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
