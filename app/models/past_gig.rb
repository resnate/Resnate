class PastGig < ActiveRecord::Base
	extend BulkMethodsMixin
	
	belongs_to :user
	acts_as_likeable
	
	validates :songkick_id, presence: true, length: { maximum: 8 }
	validates :user_id, presence: true
	validates :oneliner, presence: true, length: { maximum: 42 }
	validates :review, presence: true, length: { maximum: 5000 }


end
