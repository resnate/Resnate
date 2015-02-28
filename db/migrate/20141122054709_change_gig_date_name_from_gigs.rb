class ChangeGigDateNameFromGigs < ActiveRecord::Migration
  def change
  	rename_column :gigs, :gigDate, :gig_date
  end
end
