class PassaporteWeb::Http
  attr_reader :configuration, :token

  def initialize(configuration, token)
    @configuration = configuration
    @token = token
  end

  %i[delete get patch post put].each do |method|
    define_method method do |path, options = {}, &block|
      request(method, path, options, &block)
    end
  end

  private

  def request(method, path, options, &block)
    request = Request.new(
      method: method.to_sym,
      url: configuration.url_for(path),
      params: options[:params],
      body: options[:body],
      headers: add_headers(options[:headers]),
      multipart: options[:multipart]
    )
    Response.new(request.run).resolve!(&block)
  end

  def add_headers(headers)
    headers.merge(authorization: %(Bearer #{token}), user_agent: configuration.user_agent)
  end
end
