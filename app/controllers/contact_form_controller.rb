class ContactFormController < ApplicationController
  def new
    @form = ContactForm.new
  end

  def create
    @form = ContactForm.new(contact_form_params)
    @form.submit
    redirect_back_or_default root_path, notice: 'Thanks for your message'
  end

  private

  def contact_form_params
    params.require(:contact_form).permit(:name, :email, :message)
  end
end
