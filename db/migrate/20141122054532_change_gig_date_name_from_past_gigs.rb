class ChangeGigDateNameFromPastGigs < ActiveRecord::Migration
  def change
  	rename_column :past_gigs, :gigDate, :gig_date
  end
end
