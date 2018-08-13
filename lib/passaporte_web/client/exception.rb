# Exception class raised whenever the underlying client receives an error response.
#
# [API]
#   Documentation:
#
class PassaporteWeb::Client::Exception < StandardError
  # Creates an instance of this exception.
  #
  # @param [String] message The exception message.
  # @param [#status, #headers, #body] response The client's HTTP response object.
  def initialize(message, response)
    super(message)
    @response = response
  end

  # @return [Integer] HTTP response's status.
  def status
    @response&.status
  end

  # @return [Integer] HTTP response's headers.
  def headers
    @response&.headers
  end

  # @return [Integer] HTTP response's body.
  def body
    @response&.body || ''
  end
end
