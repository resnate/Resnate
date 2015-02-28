class AddGigDateToPastGigs < ActiveRecord::Migration
  def change
    add_column :past_gigs, :gigDate, :string
  end
end
