# frozen_string_literal: true

require 'net/http'
require 'uri'

# rubocop:disable Metrics/ClassLength
class ProfileUploader
  include ImgixRefileHelper
  include Imgix::Rails::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :user, :image

  def initialize(user)
    @user = user
  end

  def blank_base_image
    'app/assets/images/profile/base_image.png'
  end

  def image_template
    'app/assets/images/profile/new-design-blank.png'
  end

  def profile_template
    'app/assets/images/profile/profile_image_template.png'
  end

  # rubocop:disable Lint/EnsureReturn
  # rubocop:disable Lint/HandleExceptions
  def handle_network_errors(default:, max_retries: 4)
    retries = 0
    result = yield
  rescue OpenURI::HTTPError
    # No retries
  rescue Net::ReadTimeout, SocketError
    retries += 1
    retry if retries <= max_retries
  ensure
    # Need explicit return otherwise return value will be nil
    return result || default.call
  end

  def default_image_header
    MiniMagick::Image.open('app/assets/images/profile/header-bg.jpg').combine_options do |i|
      i.resize '874x462^'
      i.gravity 'Center'
      i.crop '874x462+0+0'
    end
  end

  def image_header
    handle_network_errors default: -> { default_image_header } do
      if user.profile_background_id.present? && user.profile_background_content_type.starts_with?('image/')
        url = ix_refile_image_url(user, :profile_background,
                                  auto: 'enhance,format', fit: 'crop', crop: 'edges', w: 874, h: 462)
        MiniMagick::Image.open(url)
      end
    end
  end

  def default_image_profile
    MiniMagick::Image.open('app/assets/images/profile/default_profile_image.jpeg')
  end

  def image_profile_picture
    handle_network_errors default: -> { default_image_profile } do
      if user.avatar_id.present? && user.avatar_content_type.starts_with?('image/')
        MiniMagick::Image.open('https://' + ENV.fetch('IMGIX_SOURCE') + "/store/#{user.avatar_id}")
      end
    end
  end

  def default_car_image
    MiniMagick::Image.open('app/assets/images/profile/header-bg.jpg').combine_options do |i|
      i.resize '1238x677^'
      i.gravity 'Center'
      i.crop '1238x677+0+0'
    end
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def car
    image = handle_network_errors default: -> { default_car_image } do
      car = user.cars.current.has_photos.sorted.first
      photo = car.photos.sorted.first if car
      if photo && photo.image_content_type.to_s.starts_with?('image/')
        url = ix_refile_image_url(photo, :image, auto: 'enhance,format', fit: 'crop', crop: 'edges', w: 1238, h: 677)
        text = "#{car.year} #{car.make.name} #{car.model.name}"
        point_size = case text.size
                     when 0..32 then 80
                     when 33..43 then 60
                     when 44..54 then 40
                     else
                       20
                     end
        MiniMagick::Image.open(url).combine_options do |i|
          i.font 'app/assets/fonts/helvetica.ttf'
          i.gravity 'Center'
          i.pointsize point_size
          i.fill 'Gray'
          i.draw "text 3,3 '#{text}'"
          i.fill 'White'
          i.draw "text 0,0 '#{text}'"
        end
      end
    end

    image.combine_options do |i|
      i.fill 'white'
      i.tint '70'
    end
  end

  def name_container
    name_container = MiniMagick::Image.open('app/assets/images/profile/name_template_container.png')
    result = name_container.composite(name_container) do |c|
      c.compose 'Over'
    end

    result.combine_options do |i|
      i.font 'app/assets/fonts/helvetica.ttf'
      i.gravity 'Center'
      i.pointsize 50
      i.fill 'Black'
      i.draw "text 0,0 '#{user.login}'"
    end
  end

  def counter_container
    'app/assets/images/profile/counter_container.png'
  end

  def counter_template
    'app/assets/images/profile/counter_template.png'
  end

  def generate
    header_image = image_header
    # car_image = car
    profile_image = image_profile_picture
    blank_base = MiniMagick::Image.open(blank_base_image)
    template = MiniMagick::Image.open(image_template)
    profile_template_image = MiniMagick::Image.open(profile_template)

    ### Disabled on latest template version
    # follower_counter = MiniMagick::Image.open(counter_container)
    # car_counter = MiniMagick::Image.open(counter_container)
    # followee_counter = MiniMagick::Image.open(counter_container)
    # template_counter = MiniMagick::Image.open(counter_template)
    name_template = name_container

    result = blank_base.composite(header_image) do |c|
      c.compose 'Over'
      c.geometry '+43+35'
    end

    # result = result.composite(car_image) do |c|
    #   c.compose 'Over'
    #   c.geometry '+347+1370'
    # end

    profile_image.resize '288x288'
    created_profile_image = profile_template_image.composite(profile_image) do |c|
      c.compose 'atop'
      c.gravity 'center'
    end

    result = result.composite(created_profile_image) do |c|
      c.compose 'Over'
      c.geometry '+334+355'
    end

    result = result.composite(template) do |c|
      c.compose 'Over'
    end

    #### Counter Templating ####

    ### follower Counter
    ### Disabled on latest template version
    # follower_counter = template_counter.composite(follower_counter) do |c|
    #   c.compose "Over"
    # end
    #
    # follower_counter.combine_options do |i|
    #   i.font "app/assets/fonts/helvetica.ttf"
    #   i.gravity "Center"
    #   i.pointsize 50
    #   i.draw "text 0,0 ' #{user.followers.count} '"
    # end
    #
    # result = result.composite(follower_counter) do |c|
    #   c.compose "Over"
    #   c.geometry "+718+1000"
    # end

    ### Car Counter
    ### Disabled on latest template version
    # car_counter = template_counter.composite(car_counter) do |c|
    #   c.compose "Over"
    # end
    #
    # car_counter.combine_options do |i|
    #   i.font "app/assets/fonts/helvetica.ttf"
    #   i.gravity "Center"
    #   i.pointsize 50
    #   i.draw "text 0,0 '#{user.cars.count}'"
    # end
    #
    # result = result.composite(car_counter) do |c|
    #   c.compose "Over"
    #   c.geometry "+1055+985"
    # end

    ### Followee counter
    ### Disabled on latest template version
    # followee_counter = template_counter.composite(followee_counter) do |c|
    #   c.compose "Over"
    # end
    #
    # followee_counter.combine_options do |i|
    #   i.font "app/assets/fonts/helvetica.ttf"
    #   i.gravity "Center"
    #   i.pointsize 50
    #   i.draw "text 0,0 '#{user.followees.count}'"
    # end
    #
    # result = result.composite(followee_counter) do |c|
    #   c.compose "Over"
    #   c.geometry "+1390+1000"
    # end

    @image = result.composite(name_template) do |c|
      c.compose 'Over'
      c.geometry '+45+670'
    end
  end

  def generate_and_save(inline: false)
    generate
    save inline: inline
  end

  # rubocop:disable Rails/Output
  def save(inline: false)
    if inline # For testing
      filename = "thumbnail_#{user.id}.jpg"
      image.write filename
      puts "Written to #{filename}"
    else
      image.write "tmp/thumbnail_#{user.id}.jpg"
      img = File.open(image.path)
      user.profile_thumbnail = img
      begin
        save_retries = 0
        user.save! validate: false
      rescue Seahorse::Client::NetworkingError
        save_retries += 1
        retry if save_retries == 1
      end
    end

    force_facebook_og_refresh if Rails.env.production?
  end

  def force_facebook_og_refresh
    uri = URI.parse("https://graph.facebook.com/oauth/access_token?client_id=#{ENV.fetch('FACEBOOK_APP_ID')}&" \
                    "client_secret=#{ENV.fetch('FACEBOOK_SECRET')}&grant_type=client_credentials")
    _dummy, token = Net::HTTP.get_response(uri).body.split('access_token=')

    uri = URI.parse('https://graph.facebook.com')
    params = { id: profile_url(user), scrape: true, access_token: token }
    Net::HTTP.post_form uri, params
  end

  def default_url_options
    { host: ENV.fetch('HOSTNAME') }
  end
end
