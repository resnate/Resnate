class AddGigDateToGigs < ActiveRecord::Migration
  def change
    add_column :gigs, :gigDate, :string
  end
end
