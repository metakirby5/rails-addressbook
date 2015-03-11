class HomeController < ApplicationController
  def index
    @contacts = Contact.order(created_at: :desc)

    # generate friends hash
    @friended = Hash.new(false)
    current_user.contacts.each do |contact|
      @friended[contact.id] = true
    end
  end
end
