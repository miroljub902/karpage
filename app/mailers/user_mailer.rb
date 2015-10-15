class UserMailer < ApplicationMailer
  def initialize(user)
    @user = user
    super()
  end

  def welcome_email!
    postmark.deliver_with_template(
      from: ENV['DEFAULT_MAIL_FROM'],
      to: @user.email,
      template_id: ENV['POSTMARK_TEMPLATE_WELCOME'],
      template_model: {
        action_url: user_url,
        username: @user.login.presence || @user.email
      }
    )
  end
end
