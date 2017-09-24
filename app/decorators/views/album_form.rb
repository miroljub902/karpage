# frozen_string_literal: true

module Views
  class AlbumForm < ViewDecorator
    attr_reader :max_photos

    delegate :photos, to: :object

    def initialize(options = {})
      super object: options[:form].object, **options
      @max_photos = options[:max_photos]
    end

    def create_url
      path_for(:create, object) if object.persisted?
    end

    def update_url
      path_for(:update, object, id: '_ID_') if object.persisted?
    end

    def reorder_url
      path_for(:reorder, object) if object.persisted?
    end

    private

    def path_for(operation, *args)
      case operation
      when :create
        h.public_send "#{options[:url_base]}_photos_path", *args
      when :update
        h.public_send "#{options[:url_base]}_photo_path", *args
      when :reorder
        h.public_send "reorder_#{options[:url_base]}_photos_path", *args
      end
    end
  end
end
