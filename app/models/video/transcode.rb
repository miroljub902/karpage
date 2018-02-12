class Video
  class Transcode
    attr_reader :video

    def self.call(video)
      new(video).execute!
    end

    def initialize(video)
      @video = video
    end

    def execute!
      job = transcoder.create_job(job_options)
      video.update_attributes!(
        status: Video.statuses[:processing],
        job_id: job.data.job.id,
        job_status: job.data.job.status
      )
    end

    private

    def job_options
      {
        pipeline_id: ENV.fetch('AWS_ET_PIPELINE_ID'),
          input: {
          key:          "#{Video::INPUT_PREFIX}/#{video.source_id}",
          aspect_ratio: "auto",
          container:    "auto",
          frame_rate:   "auto",
          interlaced:   "auto",
          resolution:   "auto",
          time_span:    {
            duration: "00:01:00.000"
          }
        },
        outputs: [
          {
            key:               "web.mp4",
            preset_id:         '1351620000001-100070',
            rotate:            'auto',
            thumbnail_pattern: "web-{count}"
          },
          {
            key:               "webm.webm",
            preset_id:         '1351620000001-100240',
            rotate:            'auto',
            thumbnail_pattern: "webm-{count}"
          }
        ],
        output_key_prefix: "#{Video::TEMP_PREFIX}/#{video.id}/"
      }
    end

    def transcoder
      @_transcoder ||= Aws::ElasticTranscoder::Client.new(
        access_key_id: ENV.fetch('S3_ACCESS_KEY'),
        secret_access_key: ENV.fetch('S3_SECRET_KEY'),
        region: 'us-east-1'
      )
    end
  end
end
