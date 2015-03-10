class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end

class PhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A\d{7}|\d{10,11}\z/i
      record.errors[attribute] << (options[:message] || "is not a phone number")
    end
  end
end

class Contact < ActiveRecord::Base
  validates :email,
            uniqueness: {case_sensitive: false}, email: true
  validates :phone,
            uniqueness: {case_sensitive: false}, phone: true
end
