class Gig < ActiveRecord::Base
	extend BulkMethodsMixin

	belongs_to :user
	acts_as_likeable
	default_scope -> { order('gig_date ASC') }
	validates :songkick_id, presence: true, length: { maximum: 8 }, uniqueness: true
	validates :gig_date, presence: true
	validates :user_id, presence: true

	include PublicActivity::Common

end
