history = ['http://thechive.files.wordpress.com/2010/11/oprah-bees.gif']

run lambda { |env|
  url = env['QUERY_STRING'].to_s.strip
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
          'Cache-Control' => 'public, max-age=86400'
        },
        File.open('index.html', 'rb')
      ]
    end
  else
    history << history.shift
    [302, {'Location' => "/?#{history.first}"}, []]
  end
}
