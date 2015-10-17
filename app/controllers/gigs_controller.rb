class GigsController < ApplicationController

  def create
  	@gig = current_user.gigs.build(gig_params)
    @gig.save
    @gig.create_activity :create, owner: current_user
  end

  def destroy
    @gig = Gig.find(params[:id])
    @gig.destroy
    PublicActivity::Activity.where(trackable_type: "Gig", trackable_id: @gig.id).first.destroy
      render :layout => false
  end

  def like
      @gig = Gig.find(id)
      current_user.like!(@gig)
      @like = Like.where(liker_id: current_user.id, likeable_type: "Gig", likeable_id: id).first
      @like.create_activity :create, owner: current_user
      @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Like", trackable_id: @like.id).first.id
      @message = @activity.to_s + ',' + current_user.uid.to_s
      Pusher.trigger('activities', 'feed', {:message => @message})
      render :layout => false
    end

    def unlike
      @user = User.find(params[:user])
      @gigs = Gig.where(songkick_id: Gig.find(params[:id]).songkick_id)
      @gigs.each do |gig|
        current_user.unlike!(gig)
      end
      render :layout => false
    end

    def multipleCreate
    @user = params[:user]
    @gigs = JSON.parse(params[:multiGigs])
      respond_to do |format|
        format.html { render :layout => false }
        format.json
      end
    
    end

    def gigUndo
      @gig = Gig.find_by_songkick_id(params[:songkick_id])
      @gig.destroy
      PublicActivity::Activity.where(trackable_type: "Gig", trackable_id: @gig.id).first.destroy
      render :layout => false
    end

    def friendsGoing
      @user = User.find(params[:user])
      render :layout => false
    end

  private

    def gig_params
      params.require(:gig).permit(:songkick_id, :gig_date)
    end

end
