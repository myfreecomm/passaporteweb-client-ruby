# PassaporteWeb API for resources owned by an Application
class PassaporteWeb::Client::Application
  def initialize
    @tokens = {}
  end

  def sign_up
    PassaporteWeb::Resources::SignUp.new(token(:invite))
  end

  private

  attr_reader :tokens, :credentials

  def client
    @client ||= PassaporteWeb::Client::OAuth.build
  end

  def token(scope = nil)
    token = tokens[scope]
    return token unless token.nil? || token.expired?
    tokens[scope] = client.client_credentials.get_token(scope: scope)
  end
end
