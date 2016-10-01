class ProfileUploader
  include CarrierWave::RMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  require 'mini_magick'

  storage :file

  def initialize(object)
    @user = User.find(object[:user_id])
  end

  def base_image
    'app/assets/images/base_image.png'
  end

  def image_template
    'app/assets/images/new-design-blank.png'
  end

  def image_header
    'app/assets/images/header-bg.jpg'
  end

  def image_profile_picture
    'app/assets/images/default_profile.png'
  end

  def profile_template
    'app/assets/images/profile_image_template.png'
  end

  def image_car
    'app/assets/images/header-bg.jpg'
  end

  def image_magic
    first = MiniMagick::Image.new(image_header)
    second = MiniMagick::Image.new(image_car)
    third = MiniMagick::Image.new(image_profile_picture)
    base = MiniMagick::Image.new(base_image)
    template = MiniMagick::Image.new(image_template)
    profile_image = MiniMagick::Image.new(profile_template)

    first.resize "1000x420^"
    second.resize "1000x420^"
    third.resize "340x270^"

    result = base.composite(first) do |c|
      c.compose "Over"
      c.geometry "+745+165"
    end

    result = result.composite(second) do |c|
      c.compose "Over"
      c.geometry "+745+1200"
    end

    profile_image = profile_image.composite(third) do |c|
      c.compose "In"
    end

    result = result.composite(profile_image) do |c|
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
      i.draw "text -120,-15 ' 0 '"
    end

    result.combine_options do |i|
      i.font "app/assets/fonts/helvetica.ttf"
      i.gravity "Center"
      i.pointsize 50
      i.draw "text 240,-15 '2'"
    end

    result.combine_options do |i|
      i.font "app/assets/fonts/helvetica.ttf"
      i.gravity "Center"
      i.pointsize 50
      i.draw "text 560,-15 '0'"
    end

    result.write 'test.jpg'
  end
  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def stamp(color)
    manipulate! format: "png" do |source|
      overlay_path = Rails.root.join('app/assets/images/new-design-blank.png')
      # overlay_path = Rails.root.join("app/assets/images/stamp_overlay.png")
      overlay = Magick::Image.read(overlay_path).first
      source = source.resize_to_fill(70, 70).quantize(256, Magick::GRAYColorspace).contrast(true)
      source.composite!(overlay, 0, 0, Magick::OverCompositeOp)
      colored = Magick::Image.new(70, 70) { self.background_color = color }
      colored.composite(source.negate, 0, 0, Magick::CopyOpacityCompositeOp)
    end
  end

end
