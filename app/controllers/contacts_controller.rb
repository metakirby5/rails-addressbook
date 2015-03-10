class ContactsController < ApplicationController
  def index
    @contacts = Contact.all
    render succ_json(@contacts)
  end

  def create
    @contact = Contact.create contacts_params
    if @contact.invalid?
      render err_json(@contact.errors.full_messages, 422)
    else
      render succ_json(@contact)
    end
  end

  def show
    @contact = Contact.find params[:id]
  rescue ActiveRecord::RecordNotFound => e
    render err_json([e.message], 410)
  else
    render succ_json(@contact)
  end

  def update
    @contact = Contact.update params[:id], contacts_params
  rescue ActiveRecord::RecordNotFound => e
    render err_json([e.message], 410)
  else
    if @contact.invalid?
      render err_json(@contact.errors.full_messages, 422)
    else
      render succ_json(@contact)
    end
  end

  def destroy
    @contact = Contact.destroy params[:id]
  rescue ActiveRecord::RecordNotFound => e
    render err_json([e.message], 410)
  else
    render succ_json(@contact)
  end

private
  def contacts_params
    params.permit(:name, :email, :phone)
  end

  def succ_json(data)
    {json: data.as_json(only: [:id, :name, :email, :phone])}
  end

  def err_json(errs, status)
    {json: {errors: errs}, status: status}
  end
end
