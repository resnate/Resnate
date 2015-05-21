class API::UsersController < ApplicationController
require 'json'
  def index
    @users = User.all
  end

  def show
  	@user = User.find(params[:id])
  end

  def userSearch
    me = Net::HTTP.get_response(URI.parse("https://graph.facebook.com/me?access_token=" + params[:oauth] + "&appsecret_proof=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, FACEBOOK_CONFIG['secret'], params[:oauth])))
    @profile = JSON.parse(me.body)
  end

end