class ResnatePagesController < ApplicationController
  def home
    topReviewArray = []
    
      Review.where(reviewable_type: "PastGig").each do |r|
        h = { id: r.id, likers: r.likers(User).count, likersAndAge: r.likers(User).count * 10 + r.created_at.to_i/50000 }
        topReviewArray.push(h)
      end
      @topReviews = topReviewArray.sort_by { |review| review[:likersAndAge]}.reverse.uniq

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
    if current_user.country == "United Kingdom"
      @req = Vacuum.new('GB', true)
    elsif current_user.country == "France"
      @req = Vacuum.new('FR', true)
    else
      @req = Vacuum.new('US', true)
    end
    @search_query = params[:search_query]
  	render :layout => false
  end

end
