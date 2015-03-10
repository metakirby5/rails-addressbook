class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.belongs_to :user, index: true
      t.belongs_to :contact, index: true

      t.timestamps null: false
    end
    add_foreign_key :friendships, :users
    add_foreign_key :friendships, :contacts
  end
end
