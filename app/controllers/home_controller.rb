class HomeController < ApplicationController
  def index
    @contacts = Contact.all

    # generate friends hash
    @friended = Hash.new(false)
    current_user.contacts.each do |contact|
      @friended[contact.id] = true
    end
  end
end
