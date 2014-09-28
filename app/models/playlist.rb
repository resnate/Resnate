class Playlist < ActiveRecord::Base
	
	belongs_to :user
	acts_as_followable
	default_scope -> { order('created_at DESC') }
	validates :content, presence: true
	validates :name, presence: true, presence: true, length: { maximum: 140 }
	validates :user_id, presence: true
	def self.search(query)
  		where("name LIKE ?", "%#{query}%") 
	end
	include PublicActivity::Model
tracked owner: ->(controller, model) { controller && controller.current_user }
end
