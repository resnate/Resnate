class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.text :content
      t.integer :user_id
      t.string :name

      t.timestamps
    end
    add_index :playlists, [:user_id, :created_at]
  end
end
