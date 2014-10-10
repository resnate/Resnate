class AddReviewsToPastGigs < ActiveRecord::Migration
  def change
    add_column :past_gigs, :review, :text
  end
end
