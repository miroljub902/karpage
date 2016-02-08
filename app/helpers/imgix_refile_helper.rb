module ImgixRefileHelper
  def ix_refile_image_url(obj, key, **opts)
    path = s3_path(obj, key)
    opts.merge!(default_ix_options(obj, key))
    path ? ix_image_url(path, opts) : ''
  end

  def ix_refile_image_tag(obj, key, **opts)
    path = s3_path(obj, key)
    opts.merge!(default_ix_options(obj, key))
    path ? ix_image_tag(path, opts) : ''
  end

  private

  def default_ix_options(obj, key)
    default = {
      class: "attachnent #{obj.class.model_name.to_s.downcase} #{key}"
    }
    default.merge!(rot: obj.rotate) if obj.respond_to?(:rotate) && obj.rotate.present?
    default
  end

  def s3_path(obj, key)
    refile_id = obj["#{key}_id"]
    s3_prefix = obj.send(key).try(:backend).instance_variable_get(:@prefix)

    s3_prefix ? "#{s3_prefix}/#{refile_id}" : nil
  end
end
