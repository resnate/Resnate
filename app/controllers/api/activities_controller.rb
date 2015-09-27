class API::ActivitiesController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_filter :restrict_access

	def index
    	@user = User.find(params[:id])
    	@users = []
    	@users.push(@user.id)
    	@user.followees(User).each do |user|
      	@users.push(user.id)
    	end
    	@activities = PublicActivity::Activity.where(owner_id: @users, owner_type: "User").order("created_at desc")
      paginate json: @activities, per_page: 5
  end

  def show
    @activity =  PublicActivity::Activity.find(params[:id])
  end

  def findActivityComments
    @activity =  PublicActivity::Activity.where(trackable_type: params[:trackable_type], trackable_id: params[:trackable_id]).first
    @comments = @activity.comment_threads
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