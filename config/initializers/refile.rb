require 'refile/s3'
aws = {
  access_key_id: ENV['S3_ACCESS_KEY'],
  secret_access_key: ENV['S3_SECRET_KEY'],
  bucket: ENV['S3_BUCKET'],
  region: ENV['S3_REGION']
}
Refile.store = Refile::S3.new(prefix: 'store', **aws)
Refile.cdn_host = ENV['CDN_HOST'] if ENV['CDN_HOST'].present?
