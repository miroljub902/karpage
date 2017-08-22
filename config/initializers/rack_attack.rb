# frozen_string_literal: true

class Rack::Attack
  blocklist 'bad accept header' do |req|
    /powerpoint/.match req.env['HTTP_ACCEPT']
  end
end
