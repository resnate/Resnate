class API::UsersController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods
before_filter :restrict_access, :except => :userSearch
  def index
    @users = User.all
  end

  def search
    if params[:search]
      @users = User.search(params[:search]).where.not(id: current_user.id)
    else
      @users = User.all.order('created_at DESC')
    end
  end

  def show
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
    user = User.find(params[:id])
    @points = user.points
    @level = user.level
    @level_name = user.level_name
    @followers = user.followers(User).count
    @following = user.followees(User).count
    @badges = []
    user.badges.each do |badge|
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
    paginate json: @reviews, per_page: 10
  end


  def past_gigs
    user = User.find(params[:id])
    @past_gigs = PastGig.where(user_id: params[:id]).order("created_at desc")
    paginate json: @past_gigs, per_page: 10
  end

  def upcoming_gigs
    user = User.find(params[:id])
    @upcoming_gigs = Gig.where(user_id: params[:id]).order("created_at desc")
    paginate json: @upcoming_gigs, per_page: 10
  end

  def playlists
    user = User.find(params[:id])
    @playlists = Playlist.where(user_id: params[:id]).order("created_at desc")
    paginate json: @playlists, per_page: 10
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
    paginate json: @songs, per_page: 10
  end

  def followers
      @user = User.find(params[:id])
      @followers = @user.followers(User)
      paginate json: @followers, per_page: 10
  end

  def followees
      @user = User.find(params[:id])
      @followees = @user.followees(User)
      paginate json: @followees, per_page: 10
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