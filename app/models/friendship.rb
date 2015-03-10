class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact
  validates :user_id, uniqueness: {scope: :contact_id}
end
