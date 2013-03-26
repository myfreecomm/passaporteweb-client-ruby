# encoding: utf-8
module PassaporteWeb

  class Http

    def self.get(path='/', params={})
      puts "*"*80
      puts "#{PassaporteWeb.configuration.url}#{path}"
      o = {params: params}.merge(common_params)
      puts o
      puts "*"*80
      RestClient.get(
        "#{PassaporteWeb.configuration.url}#{path}",
        {params: params}.merge(common_params)
      )
    end

    def self.put(path='/', body={}, params={})
      encoded_body = (body.is_a?(Hash) ? MultiJson.encode(body) : body)
      RestClient.put(
        "#{PassaporteWeb.configuration.url}#{path}",
        encoded_body,
        {params: params}.merge(common_params)
      )
    end

    private

    def self.common_params
      {
        authorization: PassaporteWeb.configuration.application_credentials,
        content_type: :json,
        accept: :json,
        user_agent: PassaporteWeb.configuration.user_agent
      }
    end

  end

end
