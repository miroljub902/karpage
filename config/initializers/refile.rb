require 'refile/s3'
aws = {
  access_key_id: ENV['S3_ACCESS_KEY'],
  secret_access_key: ENV['S3_SECRET_KEY'],
  bucket: ENV['S3_BUCKET'],
  region: ENV['S3_REGION']
}
Refile.store = Refile::S3.new(prefix: 'store', **aws)
Refile.cdn_host = ENV['CDN_HOST'] if ENV['CDN_HOST'].present?

%i(fit fill).each do |method|
  Refile.processor :"#{method}_and_orient" do |file, *args, format, &block|
    magick = Refile::MiniMagick.new(method)
    magick.call file, *args[0..1], format: format[:format] do |cmd|
      if args[2].present? # Manual angle
        cmd.rotate args[2].to_i
      else
        cmd.auto_orient
      end
    end
  end
end
