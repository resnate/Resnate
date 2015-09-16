class API::CommentsController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_filter :restrict_access

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
  end

  def index
  	if params[:commentable_type] == "activity"
  		@comments = PublicActivity::Activity.find(params[:commentable_id]).comment_threads
      @count = @comments.count
  	elsif params[:commentable_type] == "review"
  		@comments = Review.find(params[:commentable_id]).comment_threads
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
