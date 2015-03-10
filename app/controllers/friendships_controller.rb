class FriendshipsController < ApplicationController
  def create
    @contact = Contact.find params[:id]
  rescue ActiveRecord::RecordNotFound => e
    render err_json([e.message], 410)
  else
    begin
      @friendship = current_user.contacts << @contact
    rescue ActiveRecord::RecordInvalid => e
      render err_json(["Already friends with #{@contact.name}"], 422)
    else
      render json: {contact_id: @contact.id}
    end
  end

  def destroy

  end

private
  def succ_json(data)
    {json: data.as_json(only: :id)}
  end

  def err_json(errs, status)
    {json: {errors: errs}, status: status}
  end
end
