class PastGigsController < ApplicationController
	def create
  		@pastGig = current_user.past_gigs.build(past_gig_params)  
  		@pastGig.save 
 	end

  def pastMultipleCreate
    @user = params[:user]
    @pastGigs = JSON.parse(params[:multiGigs])
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

    def setlist
      setlistArray = params[:setlistURL].split(',')
      @artistName = setlistArray[0]
      @cityName = setlistArray[1]
      @pastGigDate = setlistArray[2]
      render :layout => false
    end


  	private

    def past_gig_params
      params.require(:past_gig).permit(:songkick_id, :gig_date)
    end
end
