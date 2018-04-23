# frozen_string_literal: true

class ViewDecorator < Draper::Decorator
  attr_reader :options
  class_attribute :_view_attrs, instance_predicate: false

  delegate :asset_path, :capture, :content_tag, to: :h

  def self.view_attrs(*attrs)
    self._view_attrs = attrs
  end

  def initialize(options = {})
    super options.delete(:object)
    @options = options
  end

  def self.render(options)
    new(options).render
  end

  def render
    h.render file: view_path.join('show'), locals: view_attrs.merge({ view: self })
  end

  private

  def view_attrs
    (_view_attrs || []).each_with_object({}) do |attr, attrs|
      attrs[attr] = self.__send__(attr)
    end
  end

  def view_path
    Rails.root.join File.dirname(__FILE__), self.class.name.underscore.sub(/_decorator$/, '')
  end
end
