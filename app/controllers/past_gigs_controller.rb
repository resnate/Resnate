class PastGigsController < ApplicationController
	def create
  		@pastGig = current_user.past_gigs.build(past_gig_params)  
  		if @pastGig.save
      
      redirect_to root_url
    else
      redirect_to root_url
    end  
 	end

  def multipleCreate
    @user = params[:user]
    @pastGigs = params[:multiGigs]
    respond_to do |format|
      format.html { render :layout => false }
      format.json
    end
    
  end

  	def destroy
  	end

    def update
      @pastGig = PastGig.find(params[:id])
      @pastGig.update_attributes(past_gig_params)
      respond_to do |format|
        format.html { redirect_to @pastGig}
        format.json  { respond_with_bip(@pastGig) }
      end
    end

    def reviewForm
      @pastGig = PastGig.where(songkick_id: params[:songkick_id], user_id: params[:user] ).first
      

      
      render :layout => false
    end

    def reviewShow
      @pastGig = PastGig.find(params[:id] )
      

      
      render :layout => false
    end

    def reviewLike
      @review = PastGig.where(songkick_id: params[:songkick_id], user_id: params[:user] ).first
      @user = User.find(params[:user])
      current_user.like!(@review)
      render :layout => false
    end

    def reviewUnlike
      @review = PastGig.where(songkick_id: params[:songkick_id], user_id: params[:user] ).first
      @user = User.find(params[:user])
      current_user.unlike!(@review)
      render :layout => false
    end

  	private

    def past_gig_params
      params.require(:past_gig).permit(:songkick_id, :oneliner, :review)
    end
end
