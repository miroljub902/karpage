# frozen_string_literal: true

class Video
  class DeleteRemote
    attr_reader :video

    def self.call(_attachable); end

    def initialize(video)
      @video = video
    end

    def execute!; end
  end
end
