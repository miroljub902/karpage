# frozen_string_literal: true

module Views
  class VideoForm < ViewDecorator
    attr_reader :attachable, :form

    def initialize(options = {})
      @attachable = options.delete(:attachable)
      @form = options.delete(:form)
      raise 'No attachable specified' unless @attachable
      options[:url_base] ||= @attachable
      super object: form.object, **options
    end

    def create_url
      path_for(:create, object.id) if object.persisted?
    end

    def update_url
      path_for(:update, object, id: '_ID_') if object.persisted?
    end

    private

    def path_for(operation, *args)
      case operation
      when :create
        h.public_send "#{options[:url_base]}_videos_path", *args
      when :update
        h.public_send "#{options[:url_base]}_video_path", *args
      end
    end
  end
end
