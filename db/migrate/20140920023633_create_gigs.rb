class CreateGigs < ActiveRecord::Migration
  def change
    create_table :gigs do |t|
      t.integer :songkick_id
      t.integer :user_id

      t.timestamps
    end
    add_index :gigs, :user_id
  end
end
