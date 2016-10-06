class ProfileUploader
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def blank_base_image
    'app/assets/images/profile/base_image.png'
  end

  def image_template
    'app/assets/images/profile/new-design-blank.png'
  end

  def image_header
    header_image =
      if user.profile_background_id
        MiniMagick::Image.open('https://' + ENV.fetch('IMGIX_SOURCE') + "/store/#{user.profile_background_id}")
      else
        MiniMagick::Image.open('app/assets/images/profile/header-bg.jpg')
      end
    header_image.resize "1000x420^"
  end

  def image_profile_picture
    if user.avatar_id
      MiniMagick::Image.open('https://'+ ENV.fetch('IMGIX_SOURCE') + "/store/#{user.avatar_id}")
    else
      MiniMagick::Image.new('app/assets/images/profile/default_profile_image.jpeg')
    end
  end

  def profile_template
    'app/assets/images/profile/profile_image_template.png'
  end

  def car
    car_image =
      if (car = user.cars.current.has_photos.sorted.first)
        car_image = MiniMagick::Image.open('https://'+ ENV.fetch('IMGIX_SOURCE') + "/store/#{car.photos.sorted.first.image_id}")
        car_image.resize "1000x420^" # this is just to make sure this image is converted before writing the text
        car_image.combine_options do |i|
          i.font "app/assets/fonts/helvetica.ttf"
          i.gravity "Center"
          i.pointsize 80
          i.fill 'White'
          i.draw "text 0,0 '#{car.year} #{car.make.name} #{car.model.name}'"
        end
      else
        MiniMagick::Image.open('app/assets/images/profile/header-bg.jpg')
      end

    car_image.combine_options do |i|
      i.colorspace 'Gray'
      i.gamma '0.5'
    end
  end

  def name_container
    name_container = MiniMagick::Image.new('app/assets/images/profile/name_template_container.png')
    result = name_container.composite(name_container) do |c|
      c.compose "Over"
    end

    result.combine_options do |i|
      i.font "app/assets/fonts/helvetica.ttf"
      i.gravity "Center"
      i.pointsize 50
      i.draw "text 0,0 '#{user.login}'"
    end
  end

  def counter_container
    'app/assets/images/profile/counter_container.png'
  end

  def counter_template
    'app/assets/images/profile/counter_template.png'
  end

  def profile_image_generator
    header_image = image_header
    car_image = car
    profile_image = image_profile_picture
    blank_base = MiniMagick::Image.new(blank_base_image)
    template = MiniMagick::Image.new(image_template)
    profile_template_image = MiniMagick::Image.new(profile_template)
    follower_counter = MiniMagick::Image.new(counter_container)
    car_counter = MiniMagick::Image.new(counter_container)
    followee_counter = MiniMagick::Image.new(counter_container)
    template_counter = MiniMagick::Image.new(counter_template)

    name_template = name_container

    profile_image.resize "335^x265"

    result = blank_base.composite(header_image) do |c|
      c.compose "Over"
      c.geometry "+713+165"
    end

    result = result.composite(car_image) do |c|
      c.compose "Over"
      c.geometry "+713+1200"
    end

    created_profile_image = profile_template_image.composite(profile_image) do |c|
      c.compose "atop"
      c.gravity "center"
    end

    result = result.composite(created_profile_image) do |c|
      c.compose "Over"
      c.geometry "+1046+455"
    end

    result = result.composite(template) do |c|
      c.compose "Over"
    end
    #### Counter Templating ####

    ### follower Counter
    follower_counter = template_counter.composite(follower_counter) do |c|
      c.compose "Over"
    end

    follower_counter.combine_options do |i|
      i.font "app/assets/fonts/helvetica.ttf"
      i.gravity "Center"
      i.pointsize 50
      i.draw "text 0,0 ' #{user.followers.count} '"
    end

    result = result.composite(follower_counter) do |c|
      c.compose "Over"
      c.geometry "+718+985"
    end

    ### Car Counter
    car_counter = template_counter.composite(car_counter) do |c|
      c.compose "Over"
    end

    car_counter.combine_options do |i|
      i.font "app/assets/fonts/helvetica.ttf"
      i.gravity "Center"
      i.pointsize 50
      i.draw "text 0,0 '#{user.cars.count}'"
    end

    result = result.composite(car_counter) do |c|
      c.compose "Over"
      c.geometry "+1055+985"
    end

    ### Followee counter
    followee_counter = template_counter.composite(followee_counter) do |c|
      c.compose "Over"
    end

    followee_counter.combine_options do |i|
      i.font "app/assets/fonts/helvetica.ttf"
      i.gravity "Center"
      i.pointsize 50
      i.draw "text 0,0 '#{user.followees.count}'"
    end

    result = result.composite(followee_counter) do |c|
      c.compose "Over"
      c.geometry "+1390+985"
    end

    result = result.composite(name_template) do |c|
      c.compose "Over"
      c.geometry "+713+725"
    end

    #### Counter Templating ####

    result.write "tmp/thumbnail_#{user.id}.jpg"
    user.profile_thumbnail = File.open(result.path)
    user.save
  end
end
