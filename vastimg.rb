class Vastimg
  def initialize(redis=$redis)
    @redis = redis
    add 'http://thechive.files.wordpress.com/2010/11/oprah-bees.gif'
  end

  def call(env)
    url = scrub(env['QUERY_STRING'])
    case url
    when /^(https?|data):/
      add url
      if env['HTTP_USER_AGENT'] =~ /Propane/
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

  def add(url)
    @redis.sadd('master', url)
  end

  def random
    @redis.srandmember('master')
  end

  def scrub(str)
    str.to_s.strip.gsub(/[\r\n\t\0]/, '').gsub('%0D', '')
  end
end
