class AddKeyToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :key, :string
  end
end
