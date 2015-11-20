class API::GigsController < ApplicationController
    include ActionController::HttpAuthentication::Token::ControllerMethods
  before_filter :restrict_access

  def show
    @gig = Gig.find(params[:id])
  end

  def friendsGoing
    user = User.find(params[:user])
    @friendsArray = []
    unless user.followees(User).count == 0
    user.followees(User).each do |friend|
        if  Gig.where(user_id: friend.id, songkick_id: params[:songkick_id].to_s ).present?
          @friendsArray.push( { "id" => friend.id } )
        end
      end
    end
    render :json => @friendsArray.to_json
  end

  def apiMultipleCreate
    @user = User.find(APIKey.find_by_access_token(params[:token]).user_id)

    current_gigs = @user.gigs
    currentArray = []
    current_gigs.each do |c|
      currentArray.push(c["songkick_id"])
    end

    new_gigs = JSON.parse(params[:multiGigs])
    gArray = []
    new_gigs.each do |g|
      if @user.gigs.find_by_songkick_id(g["songkick_id"]).nil?
        hash = { user_id: @user.id, songkick_id: g["songkick_id"], gig_date: g["gig_date"]}
        gArray.push(hash)
      end
    end



    Gig.create_many(gArray)
    gArray.each do |gA|
      gA = Gig.find_by_songkick_id(gA[:songkick_id])
      gA.create_activity :create, owner: @user
      activity = PublicActivity::Activity.where(trackable_type: "Gig", trackable_id: gA.id).first.id
      @message = activity.to_s + ',' + @user.uid.to_s
      Pusher.trigger('activities', 'feed', {:message => @message})
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