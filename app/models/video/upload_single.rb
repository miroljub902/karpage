class Video
  class UploadSingle
    attr_reader :video

    def self.call(attachable, params)
      new(attachable.video || attachable.build_video, params).tap do |op|
        Video::DeleteRemote.(op.video) if op.execute!
      end
    end

    def initialize(video, params)
      @video = video
      @params = params
    end

    def execute!
      video.update_attributes!(
        source_id: @params[:source_id],
        status: Video.statuses[:pending]
      )
      VideoTranscodingJob.perform_later(video.id)
    end
  end
end
