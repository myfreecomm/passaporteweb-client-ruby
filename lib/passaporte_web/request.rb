class PassaporteWeb::Request
  def initialize(args)
    @args = args.slice(:url, :method, :params, :body, :headers, :multipart)
  end

  def run
    request.&tap(:run).response
  end

  private

  attr_reader :args

  def request
    @request ||= Typhoeus::Request.new(args[:url], options)
  end

  def options
    compact(
      {
        method: args[:method],
        params: args[:params],
        body: Body.new(args[:body], args[:multipart]).build,
        headers: headers,
        accept_encoding: 'gzip'
      }
    )
  end

  def headers
    headers = args.fetch(:headers, {})
    compact(headers.reverse_merge('Accept': 'application/json', 'Content-Type': content_type))
  end

  def content_type
    args[:multipart] ? nil : 'application/json'
  end

  def compact(hash)
    hash.reject { |_key, value| value.blank? }
  end
end
