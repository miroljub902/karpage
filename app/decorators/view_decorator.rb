# frozen_string_literal: true

class ViewDecorator < Draper::Decorator
  attr_reader :options

  delegate :asset_path, :capture, :content_tag, to: :h

  def initialize(options = {})
    super options.delete(:object)
    @options = options
  end

  def self.render(options)
    new(options).render
  end

  def render
    h.render file: view_path.join('show'), locals: { view: self }
  end

  private

  def view_path
    Rails.root.join File.dirname(__FILE__), self.class.name.underscore.sub(/_decorator$/, '')
  end
end
