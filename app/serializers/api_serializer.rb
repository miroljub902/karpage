class ApiSerializer < ActiveModel::Serializer
  private

  def count_new_stuff(stuff, owner:)
    return 0 unless current_user
    NewStuff.count_stuff stuff, current_user, owner: owner
  end

  def url(helper_name, *args)
    options = args.extract_options!
    options.merge! host: ENV.fetch('HOSTNAME')
    args += [options]
    Rails.application.routes.url_helpers.public_send helper_name, *args
  end
end
