class API::UsersController < ApplicationController

  def index
    @users = User.all
  end

  def show
  	@user = User.find(params[:id])
  end

  def userSearch
    @graph = Koala::Facebook::API.new(params[:oauth], OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, FACEBOOK_CONFIG['secret'], params[:oauth]))
    @profile = @graph.get_object("me")
  end

end