module UrlNormalizer
  extend ActiveSupport::Concern

  included do
    cattr_accessor :_normalized_url_attributes

    before_save do
      _normalized_url_attributes.each do |attr|
        normalize_url_attribute attr
      end
    end
  end

  class_methods do
    def normalize_url(*attrs)
      self._normalized_url_attributes = attrs
    end
  end

  private

  def normalize_url_attribute(attr)
    value = self[attr]
    return if value.blank?
    value = "http://#{value}" unless value =~ /\Ahttps?:\/\//
    self[attr] = value
  end
end
