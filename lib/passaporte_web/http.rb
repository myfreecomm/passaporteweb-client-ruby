# encoding: utf-8
module PassaporteWeb

  class Http # :nodoc:

    def self.get(path='/', params={})
      get_or_delete(:get, path, params)
    end

    def self.put(path='/', body={}, params={})
      put_or_post(:put, path, body, params)
    end

    def self.post(path='/', body={}, params={})
      put_or_post(:post, path, body, params)
    end

    def self.delete(path='/', params={})
      get_or_delete(:delete, path, params)
    end

    private

    def self.put_or_post(method, path='/', body={}, params={})
      RestClient.send(
        method,
        pw_url(path),
        encoded_body(body),
        {params: params}.merge(common_params)
      )
    end

    def self.get_or_delete(method, path='/', params={})
      RestClient.send(
        method,
        pw_url(path),
        {params: params}.merge(common_params)
      )
    end

    def self.pw_url(path)
      "#{PassaporteWeb.configuration.url}#{path}"
    end

    def self.common_params
      {
        content_type: :json,
        accept: :json,
        authorization: PassaporteWeb.configuration.application_credentials,
        user_agent: PassaporteWeb.configuration.user_agent
      }
    end

    def self.encoded_body(body)
      body.is_a?(Hash) ? MultiJson.encode(body) : body
    end

  end

end
