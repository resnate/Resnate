class ActivitiesController < ApplicationController
	def index
    	@user = current_user
    	@users = []
    	@users.push(@user.id)
    	@user.followees(User).each do |user|
      		@users.push(user.id)
    	end

    	@gigArray = []
     	current_user.gigs.each do |gig|
      		@gigArray.push(gig.songkick_id)
     	end
      Like.where(liker_id: current_user.id, likeable_type: "Gig").each do |likedGig|
        @gigArray.push(Gig.find(likedGig.likeable_id).songkick_id)
      end
    	@activities = PublicActivity::Activity.where(owner_id: @users, owner_type: "User").order("created_at desc").paginate(page: params[:page], per_page: 5)

      
    	render :layout => false
  end

  def indexHeader
    render :layout => false
  end

  def show
    @activity =  PublicActivity::Activity.find(params[:id])
    @user = current_user
      @users = []
      @users.push(@user.id)
      @user.followees(User).each do |user|
          @users.push(user.id)
      end

      @gigArray = []
      current_user.gigs.each do |gig|
          @gigArray.push(gig.songkick_id)
      end
    render :layout => false
  end
end
