class Gig < ActiveRecord::Base
	belongs_to :user
	acts_as_likeable
	default_scope -> { order('created_at DESC') }
	validates :songkick_id, presence: true, length: { maximum: 8 }
	validates :user_id, presence: true

	include PublicActivity::Model
tracked owner: ->(controller, model) { controller && controller.current_user }
end
