class ProfileUploader
  def initialize(object)
    @user = User.find(object['user_id'])
  end

  def blank_base_image
    'app/assets/images/profile/base_image.png'
  end

  def image_template
    'app/assets/images/profile/new-design-blank.png'
  end

  def image_header
    header_image =
      if @user.profile_background_id
        MiniMagick::Image.open('https://'+ ENV.fetch('IMGIX_SOURCE') + "/store/#{@user.profile_background_id}")
      else
        MiniMagick::Image.new('app/assets/images/profile/header-bg.jpg')
      end
    header_image.resize "1000x420^"
    header_image = header_image.composite(transparent_cover) do |c|
      c.compose "DstOver"
    end
  end

  def image_profile_picture
    if @user.avatar_id
      MiniMagick::Image.open('https://'+ ENV.fetch('IMGIX_SOURCE') + "/store/#{@user.avatar_id}")
    else
      MiniMagick::Image.new('app/assets/images/profile/default_profile_image.jpeg')
    end
  end

  def profile_template
    'app/assets/images/profile/profile_image_template.png'
  end

  def car
    car_image =
      if cars = @user.cars
        car = cars.where(sorting: 0).first
        car_image = MiniMagick::Image.open('https://'+ ENV.fetch('IMGIX_SOURCE') + "/store/#{car.photos.sorted.first.image_id}")
        car_image.combine_options do |i|
          i.font "app/assets/fonts/helvetica.ttf"
          i.gravity "Center"
          i.pointsize 50
          i.fill 'White'
          i.draw "text 0,0 '#{car.year} #{car.make.name} #{car.model.name}'"
        end
      else
        MiniMagick::Image.new('app/assets/images/profile/header-bg.jpg')
      end

    car_image.combine_options do |i|
      i.colorspace 'Gray'
      i.gamma '0.8'
    end

    car_image.resize "1000x420^"
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
      i.draw "text 0,0 '#{@user.name}'"
    end
  end

  def transparent_cover
    cover = MiniMagick::Image.new('app/assets/images/profile/transparent_cover.png')
    cover.resize "1000x420^"
  end

  def profile_image_generator
    header_image = image_header
    car_image = car
    profile_image = image_profile_picture
    blank_base = MiniMagick::Image.new(blank_base_image)
    template = MiniMagick::Image.new(image_template)
    profile_template_image = MiniMagick::Image.new(profile_template)
    name_template = name_container

    profile_image.resize "340x270^"

    result = blank_base.composite(header_image) do |c|
      c.compose "Over"
      c.geometry "+745+165"
    end

    result = result.composite(car_image) do |c|
      c.compose "Over"
      c.geometry "+745+1200"
    end

    created_profile_image = profile_template_image.composite(profile_image) do |c|
      c.compose "In"
    end

    result = result.composite(created_profile_image) do |c|
      c.compose "Over"
      c.geometry "+1075+455"
    end

    result = result.composite(template) do |c|
      c.compose "Over"
    end

    result.combine_options do |i|
      i.font "app/assets/fonts/helvetica.ttf"
      i.gravity "Center"
      i.pointsize 50
      i.draw "text -117,-12 ' #{@user.followers.count} '"
    end

    result.combine_options do |i|
      i.font "app/assets/fonts/helvetica.ttf"
      i.gravity "Center"
      i.pointsize 50
      i.draw "text 227,-12 '2'"
    end

    result.combine_options do |i|
      i.font "app/assets/fonts/helvetica.ttf"
      i.gravity "Center"
      i.pointsize 50
      i.draw "text 557,-12 '#{@user.followees.count}'"
    end

    result = result.composite(name_template) do |c|
      c.compose "Over"
      c.geometry "+745+725"
    end

    result.path
    result.write 'public/images/temp_thumbnail_image.jpg'
    # with a regular File object
    File.open(result.path, "rb") do |file|
      @user.profile_thumbnail = file
    end

    @user.save
  end
  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
end
