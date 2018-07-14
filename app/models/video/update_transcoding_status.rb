# frozen_string_literal: true

class Video
  class UpdateTranscodingStatus
    attr_reader :video

    STATUS_MAP = {
      'Complete' => :complete,
      'Canceled' => :canceled,
      'Error'    => :error
    }.freeze

    def self.call(video)
      new(video).execute!
    end

    def initialize(video)
      @video = video
    end

    def execute!
      return if %w[Submitted Progressing].include?(job.status)

      attributes = {
        status:            Video.statuses[STATUS_MAP[job.status]],
        job_status:        job.status,
        job_status_detail: job.outputs.map do |output|
          "#{output.key}: #{output.status_detail}"
        end.join('; ')
      }

      promote!(job) if attributes[:status] == Video.statuses[:complete]
      video.assign_attributes attributes
      video.save! if video.changed?
    end

    private

    MIME_TYPES = {
      '.webm' => 'webm',
      '.mp4'  => 'mp4'
    }.freeze

    def promote!(job)
      delete_source_file
      job.outputs.each do |output|
        type = MIME_TYPES[File.extname(output.key)]
        video_url = promote_output(output.key)
        video.urls[type] = {
          source: video_url,
          thumb: video_url.sub(/#{File.extname(video_url)}$/, '.png')
        }
      end
      video.urls = video.urls # Trigger AM's dirty API
    end

    def promote_output(key)
      source       = "#{Video::TEMP_PREFIX}/#{video.id}/#{key}"
      source_thumb = source.sub(/#{File.extname(source)}$/, '-00001.png')
      target       = "#{Video::FINAL_PREFIX}/#{s3_key_prefix}/#{key}"
      target_thumb = target.sub(/#{File.extname(target)}$/, '.png')
      bucket       = ENV.fetch('S3_BUCKET')
      s3.copy_object(bucket: bucket, copy_source: "#{bucket}/#{source}", key: target)
      s3.put_object_acl(bucket: bucket, acl: 'public-read', key: target)
      s3.copy_object(bucket: bucket, copy_source: "#{bucket}/#{source_thumb}", key: target_thumb)
      s3.put_object_acl(bucket: bucket, acl: 'public-read', key: target_thumb)
      s3.delete_object(bucket: bucket, key: source)
      s3.delete_object(bucket: bucket, key: source_thumb)
      target
    end

    def delete_source_file
      s3.delete_object(bucket: ENV.fetch('S3_BUCKET'), key: "#{Video::INPUT_PREFIX}/#{video.source_id}")
    end

    def s3_key_prefix
      @_s3_key_prefix ||= video.s3_key_prefix
    end

    def s3
      @_s3 ||= Aws::S3::Client.new(
        region:            ENV.fetch('S3_REGION'),
        access_key_id:     ENV.fetch('S3_ACCESS_KEY'),
        secret_access_key: ENV.fetch('S3_SECRET_KEY')
      )
    end

    def job
      @_job ||= transcoder.read_job(id: video.job_id).job
    end

    def transcoder
      @_transcoder ||= Aws::ElasticTranscoder::Client.new(
        access_key_id:     ENV.fetch('S3_ACCESS_KEY'),
        secret_access_key: ENV.fetch('S3_SECRET_KEY'),
        region:            ENV.fetch('S3_REGION')
      )
    end
  end
end
