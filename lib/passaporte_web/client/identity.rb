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

  attr_reader :credentials
  attr_accessor :token

  ATTRIBUTES = [:access_token, :refresh_token, :expires_at, :expires_in].freeze

  def api
    token.expired? ? refresh_token : token
  end

  def client
    @client ||= PassaporteWeb::Client::OAuth.build
  end

  def hash
    ATTRIBUTES.map { |attr| [attr, credentials.send(attr)] }.to_h
  end

  def refresh_token
    token.refresh!.tap do |token|
      self.token = token
      credentials.access_token = token.token
      (ATTRIBUTES - [:access_token]).each { |attr| credentials.send("#{attr}=", token.send(attr)) }
    end
  end
end
