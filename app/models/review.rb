class Review < ActiveRecord::Base
	default_scope -> { order('created_at DESC') }
  	belongs_to :reviewable, polymorphic: true
  	belongs_to :user
  	validates :content, presence: true, length: { maximum: 7500 }
  	validates :user_id, presence: true
  	acts_as_likeable
  	include PublicActivity::Common
end
