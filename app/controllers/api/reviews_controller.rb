class API::ReviewsController < ApplicationController
  	include ActionController::HttpAuthentication::Token::ControllerMethods
	before_filter :restrict_access, :except => :userSearch

	def show
		@review = Review.find(params[:id])
    if @review.reviewable_type == "PastGig"
      @reviewableLink = PastGig.find(review.reviewable_id).songkick_id
    else
      @reviewableLink = Song.find(review.reviewable_id).content
    end
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