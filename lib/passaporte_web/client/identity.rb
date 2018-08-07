# PassaporteWeb API for resources owned by an Identity
class PassaporteWeb::Client::Identity
  def initialize(credentials)
    @credentials = credentials
    @token = OAuth2::AccessToken.from_hash(client, hash)
  end

  def profile
    PassaporteWeb::Resources::Profile.new(api)
  end

  def sign_up
    PassaporteWeb::Resources::SignUp.new(api)
  end

  private

  attr_reader :token, :credentials

  def api
    token.expired? ? refresh_token : token
  end

  def client
    @client ||= PassaporteWeb::Client::OAuth.build
  end

  def hash
    hash = [:access_token, :refresh_token, :expires_at, :expires_in].map do |attribute|
      [attribute, credentials.send(attribute)]
    end.to_h
  end

  def refresh_token
    token.refresh!
    credentials.access_token = token.access_token
    token
  end
end
