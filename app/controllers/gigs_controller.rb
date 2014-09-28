class GigsController < ApplicationController

  def create
  	@gig = current_user.gigs.build(gig_params)
    if @gig.save
      
      redirect_to root_url
    else
      redirect_to root_url
    end
  end

  def destroy
  end

  def like
      @gig = Gig.find_by_songkick_id(params[:songkick_id])
      current_user.like!(@gig)
      render :layout => false
    end

    def unlike
      @user = User.find(params[:user])
      @gigs = Gig.where(songkick_id: (params[:songkick_id]))
      @gigs.each do |gig|
        current_user.unlike!(gig)
      end
      render :layout => false
    end

    def friendsGoing
      @user = User.find(params[:user])
      render :layout => false
    end

  private

    def gig_params
      params.require(:gig).permit(:songkick_id)
    end

end
