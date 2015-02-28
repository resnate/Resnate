class ResnatePagesController < ApplicationController
  def home
    topReviewArray = []
    if Like.where(likeable_type: "Review").count > 0
      Like.where(likeable_type: "Review").each do |lR|
        h = { id: lR.likeable_id, likers: Review.find(lR.likeable_id).likers(User).count }
        topReviewArray.push(h)
      end
      @topReviews = topReviewArray.sort_by { |review| review[:likers]}.reverse.uniq
    else
      @topReviews = nil
    end

  end

  def leaderboard
    userArray = []
    User.all.each do |user|
     userPointsArray = { id: user.id, points: user.points }
      
      userArray.push(userPointsArray)
     end
    @sortedUsers = userArray.sort_by { |user| user[:points] }.reverse

    render :layout => false
    
  end

  def help
  end

  def level
    render :layout => false
    
  end

  def AmazonStore
  	render :layout => false
  end

end
