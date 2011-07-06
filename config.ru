history = ['http://thechive.files.wordpress.com/2010/11/oprah-bees.gif']

def scrub(str)
  str.to_s.strip.gsub(/[\r\n\t\0]/, '').gsub('%0D', '')
end

run lambda { |env|
  url = scrub(env['QUERY_STRING'])
  case url
  when /^(https?|data):/
    history << url if !history.include?(url)
    if env['HTTP_USER_AGENT'] =~ /Propane/
      [302, {'Location' => url}, []]
    else
      [
        200,
        {
          'Content-Type'  => 'text/html',
          'Cache-Control' => 'public, max-age=0'
        },
        File.open('index.html', 'rb')
      ]
    end
  else
    history << history.shift
    [302, {'Location' => "/?#{history.first}"}, []]
  end
}
