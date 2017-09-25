# frozen_string_literal: true

class Rack::Attack
  blocklist 'bad accept header' do |req|
    /powerpoint/.match req.env['HTTP_ACCEPT']
  end

  blocklist 'bad request' do |req|
    begin
      CGI.unescape(req.path).encode('utf-8')
      CGI.unescape(req.params.to_yaml).encode('utf-8')
      false
    rescue Encoding::UndefinedConversionError, Rack::QueryParser::InvalidParameterError, ArgumentError => e
      if e.is_a?(ArgumentError)
        raise unless e.message.match?(/invalid byte sequence/) || e.message.match?(/null byte/)
      end
      true
    end
  end

  throttle('req/ip', limit: 500, period: 5.minutes, &:ip)

  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    if (req.path == '/api/session' || req.path == '/session') && req.post?
      req.ip
    end
  end

  throttle('logins/login', limit: 5, period: 20.seconds) do |req|
    if (req.path == '/api/session' || req.path == '/session') && req.post?
      req.params['user_session'].try(:[], 'login').presence
    end
  end
end
