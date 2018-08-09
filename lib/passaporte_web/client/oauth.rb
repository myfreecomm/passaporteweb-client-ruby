require 'oauth2'

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
