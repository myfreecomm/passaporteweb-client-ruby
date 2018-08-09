require 'faraday-cookie_jar'

module Authorization

  def authorization_code
    connection = Faraday.new(url: PassaporteWeb.configuration.url) do |builder|
      builder.use :cookie_jar
      builder.adapter Faraday.default_adapter
    end

    response = connection.get('/sign_in')
    auth_token = response.body.match(%r(name="authenticity_token" value="(.+?)")).captures.first

    data = {
      'session[email]': 'luiz.buiatte@nexaas.com',
      'session[password]': '123456',
      'authenticity_token': auth_token
    }

    connection.post('/sign_in', URI.encode_www_form(data))

    response = connection.get('oauth/authorize',
      client_id: PassaporteWeb.configuration.application_token,
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
      response_type: 'code',
      scope: 'profile invite')

    if(response.headers['location'].nil? || response.headers['location'] == '')
      auth_token = response.body.match(%r(name="authenticity_token" value="(.+?)")).captures.first

      data = {
        client_id: PassaporteWeb.configuration.application_token,
        commit: 'Authorize',
        redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
        response_type: 'code',
        authenticity_token: auth_token,
        scope: 'profile invite'
      }

      response = connection.post('/oauth/authorize', URI.encode_www_form(data))
    end

    response.headers['location'].match(%r(code=(.+?)$)).captures.first
  end

  def access_token
    VCR.use_cassette('access_token', record: :new_episodes, re_record_interval: 2 * 3600) do
      client = PassaporteWeb::Client::OAuth.build
      client.auth_code.get_token(authorization_code, redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
    end
  end

  def user_credentials
    OpenStruct.new.tap do |credentials|
      token = access_token
      credentials.access_token = token.token
      credentials.refresh_token = token.refresh_token
      credentials.expires_in = token.expires_in
      credentials.expires_at = token.expires_at
    end
  end
end
