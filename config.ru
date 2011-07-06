root = File.dirname(__FILE__)
$:.unshift(root)

# configure redis
require 'redis'
redis_url = ENV['REDIS_URL'] || 'localhost:6379:2'
host, port, db = redis_url.split(':')
redis = Redis.new(:host => host, :port => port, :db => db)
warn "redis on #{[host, port, db].compact.join(':')}"

# bring in the app
require 'vastimg'
run Vastimg.new(redis)
