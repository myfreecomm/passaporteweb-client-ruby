require 'oauth2'

class PassaporteWeb::Client::OAuth

  def self.build
    OAuth2::Client.new(PassaporteWeb.configuration.application_token,
                       PassaporteWeb.configuration.application_secret,
                       site: PassaporteWeb.configuration.url)
  end
end
