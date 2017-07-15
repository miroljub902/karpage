class ContactForm
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :email, :message, presence: true

  def submit
    postmark = Postmark::ApiClient.new(ENV['POSTMARK_API_KEY'])
    postmark.deliver(
      from: "Kar Page <#{ENV['CONTACT_EMAIL']}>",
      reply_to: "#{name} <#{email}>",
      to: "Kar Page <#{ENV['CONTACT_EMAIL']}>",
      subject: 'Contact Form',
      text_body: message
    )
    clear
  end

  def message=(value)
    # Fix invalid utf8 byte sequence
    @message = value.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  end

  def clear
    self.name = ''
    self.email = ''
    self.message = ''
  end
end
