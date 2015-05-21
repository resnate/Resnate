class API::UsersController < ApplicationController

  def index
    @users = User.all
  end

  def show
  	@user = User.find(params[:id])
  end

  def userSearch
    @profile = ActiveSupport::JSON.decode(Net::HTTP.get(URI("https://graph.facebook.com/me?access_token=" + params[:oauth] + "&appsecret_proof=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, FACEBOOK_CONFIG['secret'], params[:oauth]))))
  end

end