class Song < ActiveRecord::Base
	belongs_to :user
	acts_as_likeable
	default_scope -> { order('created_at DESC') }
	validates :content, presence: true, length: { maximum: 11 }
	validates :name, presence: true, length: { maximum: 128 }
	validates :user_id, presence: true

	include PublicActivity::Common
end
