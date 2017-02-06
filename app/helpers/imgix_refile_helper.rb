module ImgixRefileHelper
  include Refile::AttachmentHelper

  def ix_refile_image_url(obj, key, **opts)
    path = s3_path(obj, key)
    opts.merge!(default_ix_options(obj, key, opts).except(:class))
    path ? ix_image_url(path, opts) : attachment_url(obj, key) # Get default if any
  end

  def ix_refile_image_tag(obj, key, **opts)
    path = s3_path(obj, key)
    opts.merge!(default_ix_options(obj, key, opts))
    path ? ix_image_tag(path, opts) : attachment_image_tag(obj, key)
  end

  private

  def default_ix_options(obj, key, opts = {})
    default = {
      class: "attachnent #{obj.class.model_name.to_s.downcase} #{key} #{opts[:class]}"
    }
    default.merge!(rot: obj.rotate) if obj.respond_to?(:rotate) && obj.rotate.present?
    crop_params = obj.send("#{key}_crop_params").try(:presence) rescue nil
    default.merge!(rect: crop_params) if crop_params && !opts.delete(:no_crop)
    default
  end

  def s3_path(obj, key)
    refile_id = obj["#{key}_id"]
    s3_prefix = obj.send(key).try(:backend).instance_variable_get(:@prefix)

    s3_prefix ? "#{s3_prefix}/#{refile_id}" : nil
  end
end
