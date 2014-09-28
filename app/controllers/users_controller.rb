class UsersController < ApplicationController

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

def recCount
  render :layout => false
end

def pointCount
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

def point1
  @user = User.find(params[:id])
  render :layout => false
end

def point5
  @user = User.find(params[:id])
  @playlist = Playlist.find(params[:playlist])
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
  @conversations = @user.mailbox.conversations
  render :layout => false
end

def notifications
  @user = User.find(params[:id])
  @conversations = @user.mailbox.conversations
  render :layout => false
end

  def index
    require 'songkick'
    require 'json'
    @client = Songkick.new("Pxms4Lvfx5rcDIuR", :json)
    @user = User.find(params[:id])
    @users = []
    @users.push(@user.id)
    @user.followees(User).each do |user|
      @users.push(user.id)
    end



     @activities = PublicActivity::Activity.where(owner_id: @users).order("created_at desc")
    render :layout => false
  end

  def pastGigs
    @user = User.find(params[:id])
    require 'songkick'
    require 'json'
    require 'geocoder'
    @client = Songkick.new("Pxms4Lvfx5rcDIuR", :json)
    @songkickID = @user.songkickID
    require 'will_paginate/array'
    @userCalendar = JSON.parse((@client.gigography(@songkickID)).to_json)["resultsPage"]["results"]["event"].paginate(page: params[:page], :per_page => 5)
    render :layout => false

end

def upcomingGigs
    @user = User.find(params[:id])
    require 'songkick'
    require 'json'
    require 'geocoder'
    @client = Songkick.new("Pxms4Lvfx5rcDIuR", :json)
    @songkickID = @user.songkickID
    require 'will_paginate/array'
    @calendarEntry = JSON.parse((@client.user_calendar(@songkickID)).to_json)["resultsPage"]["results"]["calendarEntry"].paginate(page: params[:page], :per_page => 5)
    render :layout => false

end

	def show
    	@user = User.find(params[:id])
      @songs = @user.songs
      render :layout => false
  	end

    def profile
      @user = current_user
      @songs = @user.songs
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
      render :layout => false
    end

    def unfollow
      @user = User.find(params[:user])
      current_user.unfollow!(@user)
      render :layout => false
    end

    def followers
      @user = User.find(params[:id])
      @followers = @user.followers(User)
      @users = User.all
      render :layout => false
    end

    def followees
      @user = User.find(params[:id])
      @followees = @user.followees(User)
      @users = User.all
      render :layout => false
    end


  	private


    def user_params
      params.require(:user).permit(:songkickID, :jamID, :jamName)
    end




end