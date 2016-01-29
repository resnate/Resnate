class ResnatePagesController < ApplicationController
  require 'will_paginate/array'

  def home
    if current_user.nil?
      redirect_to root_url
    end
  end

  def landing
    if current_user
      redirect_to '/home'
    end
  end

  def subscribe
    @list_id = "YOUR-LIST-ID"
    gibbon = Gibbon::API.new
    gibbon.lists(ENV["MAILCHIMP_LIST_ID"]).members.create(body: {email_address: params[:address], status: "subscribed"})
  end

  def keytest
    if Email.find_by_address(params[:address]).nil?
      redirect_to root_url
    else
      email = Email.find_by_address(params[:address])
      if email.key != params[:key]
        redirect_to root_url
      end
    end
  end

  def topReviews
    topReviewArray = []
    Review.all.each do |r|
      h = { id: r.id, likers: r.likers(User).count, likersAndAge: r.likers(User).count * 10 + r.created_at.to_i/50000 }
      topReviewArray.push(h)
    end
    @topReviews = topReviewArray.sort_by { |review| review[:likersAndAge]}.reverse.uniq.paginate(page: params[:page], per_page: 5)
    render :layout => false
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

  def apicheck
    render :layout => false
  end

  def artistSearch
    render :layout => false
  end

  def test
    render :layout => false
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
