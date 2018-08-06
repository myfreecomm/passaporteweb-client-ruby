class PassaporteWeb::Body
  def initialize(body, multipart = false)
    @body = body
    @multipart = multipart
  end

  def build
    @body.is_a?(Hash) && !@multipart ? MultiJson.encode(@body) : @body
  end

  def parse
    MultiJson.load(@body)
  rescue MultiJson::ParseError
    {}
  end
end
