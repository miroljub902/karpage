# frozen_string_literal: true

module Views
  class VideoForm < ViewDecorator
    attr_reader :attachable, :form
    view_attrs :form

    def initialize(options = {})
      @attachable = options.delete(:attachable)
      @form = options.delete(:form)
      raise 'No attachable specified' unless @attachable
      options[:url_base] ||= @attachable
      super object: form.object, **options
    end

    def delete_button
      return unless object.persisted?
      h.link_to 'Delete video', '#', data: { url: destroy_url }, class: 'btn btn-danger'
    end

    def create_url
      if object.persisted?
        path_for :create, object.id
      else
        h.videos_path
      end
    end

    def update_url
      path_for(:update, object.id, id: '_ID_') if object.persisted?
    end

    def destroy_url
      path_for(:destroy, object.id, id: video) if object.persisted?
    end

    def video_sources
      return h.content_tag(:source, nil) unless complete?

      h.safe_join(video.urls.map do |format, url|
        h.content_tag :source, nil, src: video.final_url(url['source']), format: "video/#{format}"
      end)
    end

    def video_css_class
      [
        ('video-form__video--present' if video?),
        ('video-form__video--complete' if complete?)
      ].compact.join(' ')
    end

    def processing?
      video? && video.persisted? && !video.complete?
    end

    def complete?
      video&.complete?
    end

    def video?
      video.present? && video.persisted?
    end

    def video
      object.video
    end

    private

    def path_for(operation, *args)
      case operation
      when :create
        h.public_send "#{options[:url_base]}_videos_path", *args
      when :update, :destroy
        h.public_send "#{options[:url_base]}_video_path", *args
      end
    end
  end
end
