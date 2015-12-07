class ReviewsController < ApplicationController
	def create
		@review = current_user.reviews.build(review_params)
    @review.save
    @review.create_activity :create, owner: current_user
    @activity = PublicActivity::Activity.where(trackable_type: "Review", trackable_id: @review.id).first.id
    @message = @activity.to_s + ',' + current_user.uid.to_s
    Pusher.trigger('activities', 'feed', {:message => @message})
  	render :layout => false
	end

  def destroy
    @review = Review.find(params[:id])
    @activity = PublicActivity::Activity.where(trackable_type: "Review", trackable_id: @review.id).first
    @review.destroy
    @activity.destroy
  end

  def writeReview
    @type = params[:type]
    @reviewableID = params[:id]
    render :layout => false
  end

  def update
    @review = Review.find(params[:id])
    @content = params[:content]
    @review.update_attributes(content: @content)
    render :layout => false
  end

  def updateRating
    @review = Review.find(params[:id])
    @rating = params[:rating]
    @review.update_attributes(rating: @rating)
    render :layout => false
  end

  def show
    @review = Review.find(params[:id])
    @activity = PublicActivity::Activity.where(trackable_type: "Review", trackable_id: @review.id).first
    respond_to do |format|
      format.html { render :layout => false }
      format.json
    end
  end

  def pl
    @review = Review.find(params[:id])
    if @review.reviewable_type == "PastGig"
      @name = User.find(@review.user_id).first_name + "'s Gig Review"
      @image = "https://graph.facebook.com/" + User.find(@review.user_id).uid + "/picture?width=200&height=200"
    elsif @review.reviewable_type == "Song"
      @name = User.find(@review.user_id).first_name + "'s Review of " + Song.find(@review.reviewable_id).name
      @image = "https://img.youtube.com/vi/" + Song.find(@review.reviewable_id).content + "/hqdefault.jpg"
    end
      
    if request.headers['HTTP_USER_AGENT'].eql? 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)'
      render :layout => false
    else
      redirect_to "/#reviews/" + params[:id]
    end
  end

	def like
      @review = Review.find(params[:id])
      current_user.like!(@review)
      @like = Like.where(liker_id: current_user.id, likeable_type: "Review").find_by_likeable_id(@review.id)
      @like.create_activity :create, owner: current_user
      @activity = PublicActivity::Activity.where(trackable_type: "Socialization::ActiveRecordStores::Like", trackable_id: @like.id).first.id
      @message = @activity.to_s + ',' + current_user.uid.to_s
      Pusher.trigger('activities', 'feed', {:message => @message})
      render :layout => false
    end

    def unlike
      @review = Review.find(params[:id])
      current_user.unlike!(@review)
      render :layout => false
    end

    private

    def review_params
      params.require(:review).permit(:content, :reviewable_id, :reviewable_type)
    end
end
