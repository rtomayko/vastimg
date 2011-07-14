class Vastimg
  def initialize(redis=$redis)
    @redis = redis
    add 'http://thechive.files.wordpress.com/2010/11/oprah-bees.gif'
  end

  def call(env)
    url = scrub(env['QUERY_STRING'])
    method = env['REQUEST_METHOD'].downcase
    if %[get delete].include?(method)
      send(method, url, env)
    else
      [405, {}, []]
    end
  end

  def get(url, env)
    case url
    when /^(https?|data):/
      add url
      if env['HTTP_USER_AGENT'] =~ /(Propane|Echofon)/
        [302, {'Location' => url}, []]
      else
        [
          200,
          {
            'Content-Type'  => 'text/html',
            'Cache-Control' => 'public, max-age=30'
          },
          File.open('index.html', 'rb')
        ]
      end
    else
      [302, {'Location' => "/?#{random}"}, []]
    end
  end

  def delete(url, env)
    if admin?(env)
      @redis.srem('master', url)
      [200, {}, []]
    else
      [403, {}, []]
    end
  end

  def add(url)
    @redis.sadd('master', url)
  end

  def random
    @redis.srandmember('master')
  end

  def admin?(env)
    cookies(env)['token'] == ENV['VASTIMG_ADMIN_TOKEN']
  end

  def cookies(env)
    hash = {}
    env['HTTP_COOKIE'].to_s.split(/; */).each do |cookie|
      key, value = cookie.split('=', 2)
      hash[key] = value
    end
    hash
  end

  def scrub(str)
    str.to_s.strip.gsub(/[\r\n\t\0]/, '').gsub('%0D', '')
  end
end
