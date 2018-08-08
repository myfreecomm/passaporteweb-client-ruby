# PassaporteWeb API for resources owned by an Application
class PassaporteWeb::Client::Application
  def sign_up
    PassaporteWeb::Resources::SignUp.new(token)
  end

  private

  attr_reader :token, :credentials

  def client
    @client ||= PassaporteWeb::Client::OAuth.build
  end

  def token
    @token = client.client_credentials.get_token if @token.nil? || @token.expired
    @token
  end
end
