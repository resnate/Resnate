class Playlist < ActiveRecord::Base
	
	belongs_to :user
	acts_as_followable
	default_scope -> { order('created_at DESC') }
	validates :name, presence: true, length: { maximum: 140 }
	validates :user_id, presence: true
	def self.search(query)
  		where("name ILIKE ?", "%#{query}%") 
	end
	include PublicActivity::Common
end
