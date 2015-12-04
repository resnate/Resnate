class UsersController < ApplicationController
require 'will_paginate/array'

 def search
    if params[:search]
@users = User.search(params[:search]).where.not(id: current_user.id)
else
@users = User.all.order('created_at DESC')
end
respond_to do |format|
    format.html { render "users/search", :layout => false }
    format.json
  end

end

  def autocomplete
    @users = User.all
    respond_to do |format|
      format.html
      format.json
    end
  end

  def peopleHeader
    render :layout => false  
  end

def friendsWhoLike
  @user = User.find(params[:id])
  render :layout => false
end

def artistLikes
  @user = User.find(params[:id])
  render :layout => false
end

def points
  render :layout => false
end

def point1
  @user = User.find(params[:id])
  render :layout => false
end

def pointMinus1
  @user = User.find(params[:id])
  render :layout => false
end

def point5
  @user = User.find(params[:id])
  render :layout => false
end

def pointMinus5
  @user = User.find(params[:id])
  render :layout => false
end

def userPlaylists
    @user = User.find(params[:id])
    if params[:search]
    @playlists = Playlist.search(params[:search]).where(user_id: current_user.id)
    else
    @playlists = @user.playlists
    end
    @followedPlaylists = @user.followees(Playlist).reverse
    respond_to do |format|
    format.html { render :layout => false }
    format.json
  end

  end

def conversations
  @user = User.find(params[:id])
  @likedGigs = []
  likedGigs = Like.where(likeable_type: "Gig", liker_id: params[:id])
  likedGigs.each do |like|
    @likedGigs.push(like.likeable_id)
  end
  @convos = []
  conversations = @user.mailbox.conversations
  conversations.each do |convo|
    if convo.subject[1] == "#"
      @convos.push(convo)
    end
  end
  @convos = @convos.paginate(page: params[:page], per_page: 15)
  render :layout => false
end

def lastMsg
  @user = User.find(params[:id])
  @receipts = @user.mailbox.conversations.first.receipts_for(@user)
  @receipts.each do |receipt|
    unless receipt.message.body.include?(@user.name)
      @message = receipt.message
    end
  end
  render :layout => false
end


def notifications
  @user = User.find(params[:id])
  @notifications = []
  conversations = @user.mailbox.conversations
  conversations.each do |convo|
    if convo.subject[1] == "|"
      @notifications.push(convo)
    end
  end
  @notifications = @notifications.paginate(page: params[:page], per_page: 15)
  render :layout => false
end

  def pastGigs
    @user = User.find(params[:id])
    @pastGigs = @user.past_gigs.paginate(page: params[:page], :per_page => 5)
    render :layout => false
  end

def upcomingGigs
    @user = User.find(params[:id])
    @gigs = @user.gigs.paginate(page: params[:page], :per_page => 5)
    render :layout => false

end

	def show
    	@user = User.find(params[:id])
      @songs = @user.songs
      render :layout => false
  	end

    def profile
      @user = User.find(params[:id])
      @songkickID = @user.songkickID
      @songs = @user.songs
      @pastGigs = @user.past_gigs
      @gigs = @user.gigs
      @reviews = @user.reviews
      @review = Review.where(user_id: @user.id).last
      points = @user.points
      if points < 5
        @percentToNextLevel = points/5
        @pointsToNextLevel = 5 - points
      elsif points < 10
        @percentToNextLevel = (points - 5)/5
        @pointsToNextLevel = 10 - points
      elsif points < 25
        @percentToNextLevel = (points - 10)/15
        @pointsToNextLevel = 25 - points
      elsif points < 100
        @percentToNextLevel = (points - 25)/75
        @pointsToNextLevel = 100 - points
      elsif points < 500
        @percentToNextLevel (points - 100)/400
        @pointsToNextLevel = 500 - points
      elsif points < 1000
        @percentToNextLevel = (points - 500)/500
        @pointsToNextLevel = 1000 - points
      elsif points < 10000
        @percentToNextLevel = (points - 1000)/9000
        @pointsToNextLevel = 10000 - points
      end

      render :layout => false
    end

  	def edit
    	@user = User.find(params[:id])
  	end


  	def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      
      redirect_to :root
    else
      redirect_to :root
    end   
  	end

    def follow
      @user = User.find(params[:user])
      current_user.follow!(@user)
      @follow = Follow.where(follower_id: current_user.id, followable_type: "User").find_by_followable_id(@user.id)
      @follow.create_activity :create, owner: current_user
      @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Follow", trackable_id: @follow.id).first.id.to_s
      @message = @activity + ',' + current_user.uid.to_s
      Pusher.trigger('activities', 'feed', {:message => @message})
      render :layout => false
    end

    def unfollow
      @user = User.find(params[:user])
      current_user.unfollow!(@user)
      @follow = Follow.where(follower_id: current_user.id, followable_type: "User").find_by_followable_id(@user.id)
      @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Follow", trackable_id: @follow.id).first
      @activity.destroy
      render :layout => false
    end

    def followers
      @user = User.find(params[:id])
      @followers = @user.followers(User)
      render :layout => false
    end

    def followees
      @user = User.find(params[:id])
      @followees = @user.followees(User)
      render :layout => false
    end

    def followeesUIDs
      @user = User.find(params[:id])
      @followees = @user.followees(User)
      render :layout => false
    end

    def userActivities
      @user = User.find(params[:id])
      @activities = PublicActivity::Activity.where(owner_id: @user, owner_type: "User").order("created_at desc").paginate(page: params[:page], per_page: 10)
      render :layout => false
    end

    def userReviews
      @user = User.find(params[:id])
      @reviews = Review.where(user_id: params[:id]).order("created_at desc").paginate(page: params[:page], per_page: 10)
      render :layout => false
    end

  	private


    def user_params
      params.require(:user).permit(:songkickID, :jamID, :jamName)
    end




end