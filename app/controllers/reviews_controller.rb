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
    @id = params[:id]
    render :layout => false
  end

  def update
    @review = Review.find(params[:id])
    if @review.user_id == current_user.id
      @content = params[:content]
      @review.update_attributes(content: @content)
    end
    render :layout => false
  end

  def updateRating
    @review = Review.find(params[:id])
    if @review.user_id == current_user.id
      @rating = params[:rating]
      @review.update_attributes(rating: @rating)
    end
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
      
    if current_user
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

    reviewer = User.find(@review.user_id)
    if current_user != reviewer
      lv1 = reviewer.level
      reviewer.add_points(5)
      current_user.send_message(reviewer, @like.likeable_id.to_s, "R|"+ @like.likeable_id.to_s)
      Pusher.trigger('messages', 'inbox', { message: reviewer.id, sender: current_user })
      if reviewer.device_token
        token = reviewer.device_token
        notification = Houston::Notification.new(device: token)
        notification.alert = current_user.name + " liked a review you wrote!"
        notification.sound = "sosumi.aiff"
        notification.badge = reviewer.mailbox.receipts.where(is_read:false ).count
        APN.push(notification)
      end
      lv2 = reviewer.level
      if lv1 != lv2
        reviewer.create_activity key: 'badge.create', parameters: {level: reviewer.level}, owner: reviewer
        User.find(3).send_message(reviewer, "New level: "+ reviewer.level_name, "B|"+ reviewer.level_name)
        reviewer.add_badge(reviewer.level)
        badgeActivity = PublicActivity::Activity.where(key: "badge.create", owner: reviewer).last.id
        badgeMessage = badgeActivity + ',' + current_user.uid.to_s
        Pusher.trigger('activities', 'feed', {:message => badgeMessage})
        Pusher.trigger('messages', 'inbox', { message: reviewer.id, sender: current_user })
      end
    end

    render nothing: true
  end

    def unlike
      @review = Review.find(params[:id])
      current_user.unlike!(@review)
      @user = User.find(@review.user_id)
      if current_user != @user
        lv1 = @user.level
        @user.subtract_points(5)
        lv2 = @user.level
        if lv1 != lv2
          @user.rm_badge(lv1)
        end
      end
      render nothing: true
    end

    private

    def review_params
      params.require(:review).permit(:content, :reviewable_id, :reviewable_type, :rating)
    end
end
