class Gig < ActiveRecord::Base
	extend BulkMethodsMixin

	belongs_to :user
	acts_as_likeable
	default_scope -> { order('gig_date ASC') }
	validates :songkick_id, presence: true, length: { maximum: 8 }
	validates :gig_date, presence: true
	validates :user_id, presence: true

	include PublicActivity::Common

	def self.remove_old
		Gig.all.each do |gig|
			if gig.gig_date.to_date < Date.today
				gig.destroy
			else
				puts "no old gigs"
			end
		end
		
	end
end
