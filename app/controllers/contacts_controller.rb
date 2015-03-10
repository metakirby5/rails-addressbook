class ContactsController < ApplicationController
  def index
    @contacts = Contact.all.as_json only: [:id, :name, :email, :phone]
    respond_to do |format|
      format.json {render json: @contacts}
    end
  end
  def create

  end
  def show

  end
  def update

  end
  def destroy

  end
end
