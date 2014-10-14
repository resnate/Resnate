class AddOnelinerToPastGigs < ActiveRecord::Migration
  def change
    add_column :past_gigs, :oneliner, :string
  end
end
