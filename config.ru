root = File.dirname(__FILE__)
$:.unshift(root)

# configure redis
require 'uri'
require 'redis'
url = URI.parse(ENV['REDIS_URL'] || 'redis://localhost:6379')
redis = Redis.new(:host => url.host, :port => url.port, :password => url.password)
warn "redis on #{[url.host, url.port].compact.join(':')}"

# bring in the app
require 'vastimg'
run Vastimg.new(redis)
