class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end

class PhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A(\d{7}|\d{10,11})\z/i
      record.errors[attribute] << (options[:message] || "is not a phone number")
    end
  end
end

class Contact < ActiveRecord::Base
  has_many :friendships
  has_many :users, through: :friendships

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, email: true
  validates :phone, presence: true, uniqueness: true, phone: true
end
