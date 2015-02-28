class User < ActiveRecord::Base
  extend BulkMethodsMixin
  has_merit
  require 'json'
  include PublicActivity::Common
  acts_as_follower
  acts_as_followable
  acts_as_mentionable
  acts_as_liker
  acts_as_messageable
  def self.search(query)
    where("name ILIKE ?", "%#{query}%") 
  end

  has_many :songs, dependent: :destroy
  has_many :like_songs, dependent: :destroy
  has_many :playlists, dependent: :destroy
  has_many :gigs, dependent: :destroy
  has_many :past_gigs, dependent: :destroy
  

serialize :musicLikes, JSON
serialize :friends, JSON


geocoded_by :ip_address
after_validation :geocode

reverse_geocoded_by :latitude, :longitude do |obj,results|
    if geo = results.first
      obj.city    = geo.city
      obj.country    = geo.country
    end
 end
after_validation :reverse_geocode

def self.remote_ip
    if $request.remote_ip == '127.0.0.1'
      # Hard coded remote address
      '50.78.167.161'
    else
      $request.remote_ip
    end
  end  

  def level_name
    if self.points < 5
      level_name = "Filthy Casual"
    elsif self.points < 10
      level_name = "Hipster"
    elsif self.points < 25
      level_name = "ÜberHipster"
    elsif self.points < 50
      level_name = "Groupie"
    elsif self.points < 100
      level_name = "SuperGroupie"
    elsif self.points < 500
      level_name = "Rock Star"
    elsif self.points < 1000
      level_name = "Rap God"
    elsif self.points >= 1000
      level_name = "BIGGER THAN JESUS"
    end
  end

  def level
    if self.points < 5
      level = 0
    elsif self.points < 10
      level = 1
    elsif self.points < 25
      level = 2
    elsif self.points < 50
      level = 3
    elsif self.points < 100
      level = 4
    elsif self.points < 500
      level = 5
    elsif self.points < 1000
      level = 6
    elsif self.points >= 1000
      level = 7
    end
  end

  def self.from_omniauth(auth)

    require 'net/http'
    require 'json'
    where(provider: auth.provider, uid: auth.uid, image: auth.info.image).first_or_create do |user|
    
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.first_name = auth.info.first_name
      #user.email = auth.info.email
      user.image = auth.info.image
      user.ip_address = remote_ip
      user.location = user.country 
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.info = Net::HTTP.get(URI("https://graph.facebook.com/" + auth.uid + "/music?access_token=" + user.oauth_token + "&appsecret_proof=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, FACEBOOK_CONFIG['secret'], user.oauth_token) + '&limit=1000'))
      
      data = (ActiveSupport::JSON.decode(user.info))["data"]

      unless data.empty?
      arr = []
      data.each do |d|
          arr.push(d["name"])
      end
      user.musicLikes = arr
      end


      friendsInfo = Net::HTTP.get(URI("https://graph.facebook.com/" + auth.uid + "/friends?fields=installed&access_token=" + user.oauth_token + "&appsecret_proof=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, FACEBOOK_CONFIG['secret'], user.oauth_token)))
      unless friendsInfo == nil
        friendsData = (ActiveSupport::JSON.decode(friendsInfo))["data"]
        fArr = []
        friendsData.each do |fD|
          if fD["installed"] == true
            fArr.push(fD["id"])
          end
        end
      end

      user.friends = fArr

      user.save!

    end
  end



def mailboxer_email(user)
 user.email
end

  
end