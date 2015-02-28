class Review < ActiveRecord::Base
  belongs_to :reviewable, polymorphic: true
  validates :content, presence: true, length: { maximum: 5000 }
  acts_as_likeable
  include PublicActivity::Common

  def self.build_from(obj, content)
    new \
      :reviewable => obj,
      :content        => content
  end
end
