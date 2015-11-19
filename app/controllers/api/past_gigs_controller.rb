class API::PastGigsController < ApplicationController
  	include ActionController::HttpAuthentication::Token::ControllerMethods
	before_filter :restrict_access, :except => :userSearch

	def show
		@past_gig = PastGig.find(params[:id])
	end

  def review
    @review = Review.where(reviewable_type: "PastGig", reviewable_id: params[:id]).first
  end

  def apiPastMultipleCreate
    @user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    @pastGigs = JSON.parse(params[:multiGigs])
    pgArray = []
    @pastGigs.each do |pg|
      if @user.past_gigs.find_by_songkick_id(pg["songkick_id"]).nil?
        hash = { user_id: @user.id, songkick_id: pg["songkick_id"], gig_date: pg["gig_date"] }
        pgArray.push(hash)
      end
    end
    PastGig.create_many(pgArray)
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