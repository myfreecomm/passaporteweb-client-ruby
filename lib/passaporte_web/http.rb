# encoding: utf-8
module PassaporteWeb

  class Http # :nodoc:

    def self.get(path='/', params={}, type='application')
      RestClient.get(
        pw_url(path),
        {params: params}.merge(common_params(type))
      )
    end

    def self.put(path='/', body={}, params={}, type='application')
      encoded_body = (body.is_a?(Hash) ? MultiJson.encode(body) : body)
      RestClient.put(
        pw_url(path),
        encoded_body,
        {params: params}.merge(common_params(type))
      )
    end

    def self.post(path='/', body={}, type='application')
      encoded_body = (body.is_a?(Hash) ? MultiJson.encode(body) : body)
      RestClient.post(
        pw_url(path),
        encoded_body,
        common_params(type)
      )
    end

    def self.delete(path='/', params={}, type='application')
      RestClient.delete(
        pw_url(path),
        {params: params}.merge(common_params(type))
      )
    end

    private

    def self.pw_url(path)
      "#{PassaporteWeb.configuration.url}#{path}"
    end

    def self.common_params(type)
      {
        authorization: if type.eql? 'application' then PassaporteWeb.configuration.application_credentials else PassaporteWeb.configuration.user_credentials end,
        content_type: :json,
        accept: :json,
        user_agent: PassaporteWeb.configuration.user_agent
      }
    end

  end

end