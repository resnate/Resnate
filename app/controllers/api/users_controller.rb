class API::UsersController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
before_filter :restrict_access, :except => :userSearch
  def index
    @users = User.all
  end

  def search
    if params[:search]
      @users = User.search(params[:search]).where.not(id: params[:id])
    else
      @users = User.all.order('created_at DESC')
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def login
    unless User.find_by_uid(params[:id]).nil?
  	 @user = User.find_by_uid(params[:id])
    else 
      @user = nil
    end
  end

  def userSearch
    @profile = JSON.parse(Net::HTTP.get_response(URI.parse("https://graph.facebook.com/me?access_token=" + params[:oauth] + "&appsecret_proof=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, FACEBOOK_CONFIG['secret'], params[:oauth]))).body.html_safe)["id"]
    if User.find_by_uid(@profile).nil?
      @profile = nil
    else
      id = User.find_by_uid(@profile).id
      @access_token = APIKey.find_by_user_id(id).access_token
      @name = User.find(id).name
      @first_name = User.find(id).first_name
    end
  end

  def level
    @user = User.find(params[:id])
    @points = @user.points
    @level = @user.level
    @level_name = @user.level_name
    @followers = @user.followers(User).count
    @following = @user.followees(User).count
    @badges = []
    @user.badges.each do |badge|
      @badges.push(badge.name)
    end
  end

  def profile
    user = User.find(params[:id])
    @id = params[:id]
    @userID = user.uid
    @name = user.name
    @first_name = user.first_name
    if user.reviews.count == 0
      @review = nil
      @reviewable_type = nil
    else
      review = user.reviews.last
      if review.reviewable_type == "PastGig"
        @reviewable_type = "PastGig"
        @review = "https://api.songkick.com/api/3.0/events/#{PastGig.find(review.reviewable_id).songkick_id}.json?apikey=Pxms4Lvfx5rcDIuR"
      else
        @reviewable_type = "Song"
        @review = "https://img.youtube.com/vi/#{Song.find(review.reviewable_id).content}/hqdefault.jpg"
      end
    end
    @songkickID = user.songkickID
    if @songkickID.nil?
      @pastGig = nil
      @upcomingGig = nil
    else
      if user.past_gigs.count == 0
        @pastGig = nil
      else
        pg = user.past_gigs.first
        @pastGig = "https://api.songkick.com/api/3.0/events/#{pg.songkick_id}.json?apikey=Pxms4Lvfx5rcDIuR"
      end
      if user.gigs.count == 0
        @upcomingGig = nil
      else
        g = user.gigs.first
        @upcomingGig = "https://api.songkick.com/api/3.0/events/#{g.songkick_id}.json?apikey=Pxms4Lvfx5rcDIuR"
      end
    end
    if user.playlists.count == 0 || user.playlists.first.content.nil?
      @playlist = nil
    else
      playlist = user.playlists.first
      img1 = "a"
      JSON.parse(playlist.content)[0].each do |k, v|
        img1 = v
      end
      @playlist = "https://img.youtube.com/vi/#{img1}/hqdefault.jpg"
    end
  end

  def reviews
    user = User.find(params[:id])
    @reviews = Review.where(user_id: params[:id]).order("created_at desc")
    paginate json: @reviews, page: params[:page], per_page: 5
  end


  def past_gigs
    user = User.find(params[:id])
    @past_gigs = PastGig.where(user_id: params[:id]).order("created_at desc")
    paginate json: @past_gigs, page: params[:page], per_page: 5
  end

  def upcoming_gigs
    user = User.find(params[:id])
    @upcoming_gigs = Gig.where(user_id: params[:id]).order("created_at desc")
    paginate json: @upcoming_gigs, page: params[:page], per_page: 5
  end

  def playlists
    user = User.find(params[:id])
    @playlists = Playlist.where(user_id: params[:id]).order("created_at desc")
    paginate json: @playlists, page: params[:page, per_page: 25
  end

  def likes
    user = User.find(params[:id])
    if Like.where(liker_id: user.id, likeable_type: "Song").count === 0
      @songs = nil
    else
      @songs = []
      Like.where(liker_id: user.id, likeable_type: "Song").each do |song|
        @songs.push(Song.find(song.likeable_id))
      end
    end
    paginate json: @songs, page: params[:page, per_page: 25
  end

  def followers
      @user = User.find(params[:id])
      @followers = @user.followers(User)
      paginate json: @followers, page: params[:page], per_page: 10
  end

  def followees
      @user = User.find(params[:id])
      @followees = @user.followees(User)
      paginate json: @followees, page: params[:page], per_page: 10
  end

  def followeeIDs
    user = User.find(params[:id])
    @IDsArray = []
    unless user.followees(User).count == 0
      user.followees(User).each do |followee|
        @IDsArray.push( { "id" => followee.id } )
      end
    end
    render :json => @IDsArray.to_json
  end

  def follow
    @user = User.find(params[:user])
    current_user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    current_user.follow!(@user)
    @follow = Follow.where(follower_id: current_user.id, followable_type: "User").find_by_followable_id(@user.id)
    @follow.create_activity :create, owner: current_user
    @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Follow", trackable_id: @follow.id).first.id.to_s
    @message = @activity + ',' + current_user.uid.to_s
    Pusher.trigger('activities', 'feed', {:message => @message})
  end

  def unfollow
    @user = User.find(params[:user])
    current_user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    current_user.unfollow!(@user)
    @follow = Follow.where(follower_id: current_user.id, followable_type: "User").find_by_followable_id(@user.id)
    @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Follow", trackable_id: @follow.id).first
    @activity.destroy
  end

  def userActivities
    @user = User.find(params[:id])
    @activities = PublicActivity::Activity.where(owner_id: @user, owner_type: "User").order("created_at desc")
    paginate json: @activities, per_page: 5
  end

  def unread
    @unreadMessages = 0
    @newPoints = 0
    @user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    unless @user.mailbox.receipts.where(is_read:false ).count == 0
      @user.mailbox.receipts.where(is_read:false, ).each do |receipt|
        if receipt.message.subject[1] == "|"
          @newPoints += 1
        else
          @unreadMessages += 1
        end
      end
    end
  end

  def lastMsg
    @user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    @messages = []
    @conversation = @user.mailbox.conversations.first
    @receipts = @conversation.receipts_for(@user)
    @receipts.each do |receipt|
      message = receipt.message
      @messages.push(message: message, participants: @conversation.participants)
    end
    paginate json: @messages, per_page: 1
  end

  def markAsRead
    @user = User.find(APIKey.find_by_access_token(params[:token]).user_id)
    conversations = @user.mailbox.conversations
    conversations.each do |convo|
      if params[:type] == "message"
        if convo.subject[1] == "#"
          convo.mark_as_read(@user)
        end
      elsif params[:type] == "notification"
        if convo.subject[1] == "|"
          convo.mark_as_read(@user)
        end
      end
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