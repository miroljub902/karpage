class Rack::Attack
  blocklist 'bad accept header' do |req|
    req.env['HTTP_ACCEPT'] === /powerpoint/
  end
end
