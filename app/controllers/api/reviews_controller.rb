class API::ReviewsController < ApplicationController
  	include ActionController::HttpAuthentication::Token::ControllerMethods
	before_filter :restrict_access, :except => :userSearch

	def show
		@review = Review.find(params[:id])
	end

  def create
    @review = current_user.reviews.build(review_params)
    @review.save
    @review.create_activity :create, owner: current_user
    @activity = PublicActivity::Activity.where(trackable_type: "Review", trackable_id: @review.id).first.id
    @message = @activity.to_s + ',' + current_user.uid.to_s
    Pusher.trigger('activities', 'feed', {:message => @message})
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
        params.require(:review).permit(:content, :reviewable_id, :reviewable_type)
      end
end