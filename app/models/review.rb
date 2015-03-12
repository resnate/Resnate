class Review < ActiveRecord::Base
  belongs_to :reviewable, polymorphic: true
  validates :content, presence: true, length: { maximum: 5000 }
  validates :user_id, presence: true
  acts_as_likeable
  include PublicActivity::Common

  def self.build_from(obj, content, user)
    new \
      :reviewable => obj,
      :content        => content,
      :user_id => user
  end
end
