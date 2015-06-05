class PastGig < ActiveRecord::Base
	extend BulkMethodsMixin
	
	belongs_to :user
	acts_as_likeable
	has_one :review, as: :reviewable

	default_scope -> { order('gig_date DESC') }
	
	validates :songkick_id, presence: true, length: { maximum: 8 }
	validates :gig_date, presence: true
	validates :user_id, presence: true
	

end
