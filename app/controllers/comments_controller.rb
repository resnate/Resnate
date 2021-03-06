class CommentsController < ApplicationController

  def create
    recipients = []
    @commentable = PublicActivity::Activity.find(params[:commentable_id]) 
    recipient = User.find(@commentable.owner_id)
    if @commentable.trackable_type == "Song"    
      notification = "C|S" + (params[:commentable_id]).to_s
    elsif @commentable.trackable_type == "Playlist"    
      notification = "C|P" + (params[:commentable_id]).to_s
    elsif @commentable.trackable_type == "Gig"    
      notification = "C|G" + (params[:commentable_id]).to_s
    elsif @commentable.trackable_type == "Review"
      notification = "C|R" + (params[:commentable_id]).to_s
    end    

    if @commentable.owner_id != current_user.id
      recipients.push(recipient)
    end

    @get = "/activity/" + params[:commentable_id] + "/comments/"
    @comment = Comment.build_from( @commentable, current_user.id, params[:body] )
    @comment.save
    Pusher.trigger('comments', 'comment', {:message => @get})

    Comment.where(commentable_id: params[:commentable_id]).each do |c|
      if c.user_id != @commentable.owner_id && c.user_id != current_user.id
        recipients.push(User.find(c.user_id))
      end
    end

    recipients = recipients.uniq

    current_user.send_message(recipients, params[:body], notification)
    recipients.each do |r|
      Pusher.trigger('messages', 'inbox', { message: r.id, sender: @sender})
      if r.device_token
        token = r.device_token
        pushNotification = Houston::Notification.new(device: token)
        if @commentable.trackable_type == "Song"
          pushNotification.alert = current_user.name + " commented on " + Song.find(params[:commentable_id]).name
        elsif @commentable.trackable_type == "Playlist"
          pushNotification.alert = current_user.name + " commented on " + Playlist.find(params[:commentable_id]).name
        elsif @commentable.trackable_type == "Gig"
          pushNotification.alert = current_user.name + " commented on a gig you'll be attending."
        elsif @commentable.trackable_type == "Review"
          pushNotification.alert = current_user.name + " commented on a review."
        end
        pushNotification.sound = "sosumi.aiff"
        pushNotification.badge = r.mailbox.receipts.where(is_read:false ).count
        APN.push(pushNotification)
      end
    end
  	render nothing: true
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
    render nothing: true
  end

end
