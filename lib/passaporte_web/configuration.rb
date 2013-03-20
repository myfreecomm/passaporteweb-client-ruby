# encoding: utf-8
require 'base64'
module PassaporteWeb

  class Configuration
    attr_accessor :url, :user_agent, :application_token, :application_secret, :user_token, :user_secret

    def initialize
      @url = 'https://app.passaporteweb.com.br'
      @user_agent = "PassaporteWeb Ruby Client v#{PassaporteWeb::VERSION}"
      @application_token = nil
      @application_secret = nil
      @user_token = nil
      @user_secret = nil
    end

    def application_credentials
      check_tokens! :application_token, :application_secret
      base64_credential(@application_token, @application_secret)
    end

    def user_credentials
      check_tokens! :user_token, :user_secret
      base64_credential(@user_token, @user_secret)
    end

    private

    def check_tokens!(*tokens)
      tokens.each do |token|
        value = instance_variable_get("@#{token}".to_sym)
        raise ArgumentError, "#{token} not set" if value.nil? || value.to_s.strip == ''
      end
    end

    def base64_credential(user, password)
      "Basic #{::Base64.strict_encode64("#{user}:#{password}")}"
    end
  end

end
