class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.string :email
      t.string :image
      t.string :oauth_token
      t.datetime :oauth_expires_at
      t.string :location
      t.text :info
      t.text :musicLikes
      t.string :songkickID
      t.string :jamID
      t.string :first_name
      t.string :jamName
      t.string :ip_address
      t.float :latitude
      t.float :longitude
      t.string :address
      t.string :city
      t.string :country
      t.text :friends

      t.timestamps
    end
  end
end
