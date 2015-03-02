class ReviewsController < ApplicationController
	def create
		@reviewable = PastGig.find(params[:reviewable_id])
		@review = Review.build_from( @reviewable, params[:content] )
    @review.save
    @review.create_activity :create, owner: current_user
    @activity = PublicActivity::Activity.where(trackable_type: "Review", trackable_id: @review.id).first
  	render :layout => false
	end

  def show
    @review = Review.find(params[:id])
    @activity = PublicActivity::Activity.where(trackable_type: "Review", trackable_id: @review.id).first
    render :layout => false
  end

	def like
      @review = Review.find(params[:id])
      current_user.like!(@review)
      @like = Like.where(liker_id: current_user.id, likeable_type: "Review").find_by_likeable_id(@review.id)
      @like.create_activity :create, owner: current_user
      @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Like", trackable_id: @like.id).first
      render :layout => false
    end

    def unlike
      @user = User.find(params[:user])
      @review = Review.find(params[:id])
      current_user.unlike!(@review)
      render :layout => false
    end
end
