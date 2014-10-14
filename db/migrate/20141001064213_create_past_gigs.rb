class CreatePastGigs < ActiveRecord::Migration
  def change
    create_table :past_gigs do |t|
      t.integer :songkick_id
      t.integer :user_id

      t.timestamps
    end
    add_index :past_gigs, :user_id
  end
end
