class API::UsersController < ApplicationController

  def index
    @users = User.all
  end

  def show
  	@user = User.find(params[:id])
  end

  def userSearch
    @profile = JSON.parse(Net::HTTP.get_response(URI.parse("https://graph.facebook.com/me?access_token=" + params[:oauth] + "&appsecret_proof=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, FACEBOOK_CONFIG['secret'], params[:oauth]))).body.html_safe)["id"]
    if User.find_by_uid(@profile).nil?
      @profile = nil
    end
  end

end