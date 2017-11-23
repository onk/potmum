# frozen_string_literal: true

Boffin.config do |c|
  c.redis = Redis.new(url: ENV['REDIS_URL'])
end
