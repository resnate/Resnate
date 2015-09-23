class API::ReviewsController < ApplicationController
  	include ActionController::HttpAuthentication::Token::ControllerMethods
	before_filter :restrict_access

	def show
		@review = Review.find(params[:id])
	end

  def create
    
      current_user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    
    @review = current_user.reviews.build(review_params)
    @review.save
    @review.create_activity :create, owner: current_user
    @activity = PublicActivity::Activity.where(trackable_type: "Review", trackable_id: @review.id).first.id
    @message = @activity.to_s + ',' + current_user.uid.to_s
    Pusher.trigger('activities', 'feed', {:message => @message})
  end

  def update
    current_user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    @review = Review.find(params[:id])

    if current_user.id == @review.user_id
      @content = params[:content]
      @review.update_attributes(content: @content)
    end
  end

  def destroy
    current_user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    @review = Review.find(params[:id])

    if current_user.id == @review.user_id
      @activity = PublicActivity::Activity.where(trackable_type: "Review", trackable_id: @review.id).first
      @review.destroy
      @activity.destroy
    end

    
  end

  def likes
    @likers = Review.find(params[:id]).likers(User)
    @count = @likers.count

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

      def review_params
        params.require(:review).permit(:content, :reviewable_id, :reviewable_type, :user_id)
      end
end