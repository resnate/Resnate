class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.string :content
      t.integer :user_id
      t.string :name

      t.timestamps
    end
    add_index :songs, [:user_id, :created_at]
  end
end
