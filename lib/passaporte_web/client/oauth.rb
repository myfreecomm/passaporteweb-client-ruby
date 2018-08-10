require 'oauth2'

# OAuth2 client used by PassaporteWeb::Client::Application and PassaporteWeb::Client::Identity.
# Provides direct access to the underlying OAuth2 API.
class PassaporteWeb::Client::OAuth

  def self.build
    config = PassaporteWeb.configuration
    OAuth2::Client.new(config.application_token,
                       config.application_secret,
                       site: config.url,
                       connection_opts: { headers: headers })
  end

  private

  def self.headers
    { 'Accept': 'application/json', 'Content-type': 'application/json' }
  end
end
