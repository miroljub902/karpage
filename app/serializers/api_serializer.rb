class ApiSerializer < ActiveModel::Serializer
  private

  def url(helper_name, *args)
    options = args.extract_options!
    options.merge! host: ENV.fetch('HOSTNAME')
    args += [options]
    Rails.application.routes.url_helpers.public_send helper_name, *args
  end
end
