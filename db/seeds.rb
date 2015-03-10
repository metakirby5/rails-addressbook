# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Contacts
Contact.create [
  {
      name:   'Ethan',
      email:  'me@ethan.com',
      phone:  '(xxx) xxx-xxxx',
  },
  {
      name:   'Richard',
      email:  'me@richard.com',
      phone:  '(yyy) yyy-yyyy',
  },
  {
      name:   'Kavin',
      email:  'me@askkav.in',
      phone:  '(zzz) zzz-zzzz',
  },
]
