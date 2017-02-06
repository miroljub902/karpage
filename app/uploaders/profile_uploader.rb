require 'net/http'
require 'uri'

class ProfileUploader
  include ImgixRefileHelper
  include Imgix::Rails::UrlHelper
  include Rails.application.routes.url_helpers

  attr_reader :user, :tempfiles

  def initialize(user)
    @user = user
  end

  def blank_base_image
    'app/assets/images/profile/base_image.png'
  end

  def image_template
    'app/assets/images/profile/new-design-blank.png'
  end

  def default_image_header
    MiniMagick::Image.open('app/assets/images/profile/header-bg.jpg').combine_options do |i|
      i.resize '1235x658^'
      i.gravity 'Center'
      i.crop '1235x658+0+0'
    end
  end

  def image_header
    retries = 0
    if user.profile_background_id.present? && user.profile_background_content_type.starts_with?('image/')
      url = ix_refile_image_url(user, :profile_background, auto: 'enhance,format', fit: 'crop', crop: 'edges', w: 1235, h: 658)
      MiniMagick::Image.open(url)
    else
      default_image_header
    end
  rescue OpenURI::HTTPError
    default_image_header
  rescue Net::ReadTimeout
    retries += 1
    retry if retries < 4
    default_image_header
  end

  def default_image_profile
    MiniMagick::Image.open('app/assets/images/profile/default_profile_image.jpeg')
  end

  def image_profile_picture
    retries = 0
    if user.avatar_id.present? && user.avatar_content_type.starts_with?('image/')
      MiniMagick::Image.open('https://' + ENV.fetch('IMGIX_SOURCE') + "/store/#{user.avatar_id}")
    else
      default_image_profile
    end
  rescue OpenURI::HTTPError
    default_image_profile
  rescue Net::ReadTimeout
    retries += 1
    retry if retries < 4
    default_image_profile
  end

  def profile_template
    'app/assets/images/profile/profile_image_template.png'
  end

  def default_car_image
    MiniMagick::Image.open('app/assets/images/profile/header-bg.jpg').combine_options do |i|
      i.resize '1238x677^'
      i.gravity 'Center'
      i.crop '1238x677+0+0'
    end
  end

  def car
    retries = 0
    car = user.cars.current.has_photos.sorted.first
    photo = car.photos.sorted.first if car
    car_image =
      if photo && photo.image_content_type.starts_with?('image/')
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
      else
        default_car_image
      end
  rescue OpenURI::HTTPError
    car_image = default_car_image
  rescue Net::ReadTimeout
    retries += 1
    retry if retries < 4
    car_image = default_car_image
  ensure
    car_image.combine_options do |i|
      i.fill 'white'
      i.tint '70'
    end
    car_image
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

  def generate(inline: false)
    header_image = image_header
    car_image = car
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
      c.geometry '+348+230'
    end

    result = result.composite(car_image) do |c|
      c.compose 'Over'
      c.geometry '+347+1370'
    end

    profile_image.resize '409x408'
    created_profile_image = profile_template_image.composite(profile_image) do |c|
      c.compose 'atop'
      c.gravity 'center'
    end

    result = result.composite(created_profile_image) do |c|
      c.compose 'Over'
      c.geometry '+761+685'
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

    result = result.composite(name_template) do |c|
      c.compose 'Over'
      c.geometry '+348+1110'
    end

    if inline # For testing
      filename = "thumbnail_#{user.id}.jpg"
      result.write filename
      puts "Written to #{filename}"
    else
      result.write "tmp/thumbnail_#{user.id}.jpg"
      user.profile_thumbnail = File.open(result.path)
      user.save
    end

    force_facebook_og_refresh if Rails.env.production?
  end

  def force_facebook_og_refresh
    uri = URI.parse('https://graph.facebook.com')
    params = { id: profile_url(user), scrape: true }
    Net::HTTP.post_form uri, params
  end

  def default_url_options
    { host: ENV.fetch('HOSTNAME') }
  end
end
