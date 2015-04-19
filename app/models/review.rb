class Review < ActiveRecord::Base
  belongs_to :reviewable, polymorphic: true
  belongs_to :user
  validates :content, presence: true, length: { maximum: 5000 }
  validates :user_id, presence: true
  acts_as_likeable
  include PublicActivity::Common
end
