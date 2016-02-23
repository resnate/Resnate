class API::CommentsController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_filter :restrict_access

  def create
    userID = APIKey.find_by_access_token(params[:token]).user_id
    recipients = []
  	if params[:commentable_type] == "activity"
      @commentable = PublicActivity::Activity.find(params[:commentable_id]) 
      recipient = @commentable.owner_id
      if @commentable.trackable_type == "Song"    
        notification = "C|S"
      elsif @commentable.trackable_type == "Playlist"    
        notification = "C|P"
      elsif @commentable.trackable_type == "Gig"    
        notification = "C|G"
      end
    elsif params[:commentable_type] == "review"
  		@commentable = Review.find(params[:commentable_id])
      recipient = @commentable.user_id
      notification = "C|R"
  	end

    recipients.push(recipient)

    @get = "/activity/" + params[:commentable_id] + "/comments/"
    @body = params[:body] 
    @comment = Comment.build_from( @commentable, userID, params[:body] )
    @comment.save
    Pusher.trigger('comments', 'comment', {:message => @get})

    user = User.find(userID)

    Comment.where(commentable_id: params[:commentable_id]).each do |c|
      if c.user_id != @commentable.owner_id && c.user_id != userID
        recipients.push(User.find(c.user_id))
      end
    end

    recipients = recipients.uniq
    
    user.send_message(recipients, params[:body], notification)
    recipients.each do |r|
      Pusher.trigger('messages', 'inbox', { message: r.id, sender: @sender})
    end
  end

  def index
  	if params[:commentable_type] == "activity"
  		@comments = PublicActivity::Activity.find(params[:commentable_id]).comment_threads
  	end
  end

  def count
    if params[:commentable_type] == "activity"
      activity = PublicActivity::Activity.find(params[:commentable_id])
      @comments = activity.comment_threads
      @commentsCount = @comments.count

      if activity.trackable_type == "Song"
        @likesCount = Like.where(likeable_type: "Song", likeable_id: activity.trackable_id ).count
      elsif activity.trackable_type == "Gig"
        @likesCount = Like.where(likeable_type: "Gig", likeable_id: activity.trackable_id ).count
      elsif activity.trackable_type == "User"
        @likesCount = 0
      end

    elsif params[:commentable_type] == "review"
      @comments = Review.find(params[:commentable_id]).comment_threads
      @commentsCount = @comments.count
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
  end

  private
    def restrict_access
      authenticate_or_request_with_http_token do |token, options|
        APIKey.exists?(access_token: token)
      end

      def request_http_token_authentication(realm = "Application")  
        self.headers["WWW-Authenticate"] = %(Token realm="#{realm.gsub(/"/, "")}")
        self.__send__ :render, :json => { :error => "HTTP Token: Access denied. You did not provide an valid API key." }.to_json, :status => :unauthorized
      end
    end

end
