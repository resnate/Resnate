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
  @conversations = @user.mailbox.conversations.paginate(page: params[:page], per_page: 10)
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
  @conversations = @user.mailbox.conversations.paginate(page: params[:page], per_page: 10)
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
      @reviews = Review.where(user_id: @user.id)
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
      @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Follow", trackable_id: @follow.id).first.id
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

    def userActivities
      @user = User.find(params[:id])
      @activities = PublicActivity::Activity.where(owner_id: @user, owner_type: "User").order("created_at desc").paginate(page: params[:page], per_page: 10)
      render :layout => false
    end


  	private


    def user_params
      params.require(:user).permit(:songkickID, :jamID, :jamName)
    end




end