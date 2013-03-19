# encoding: utf-8
require 'base64'
module PassaporteWeb

  class Configuration
    attr_accessor :url, :application_token, :application_secret, :user_token, :user_secret

    def initialize
      @url = 'https://app.passaporteweb.com.br'
      @application_token = nil
      @application_secret = nil
      @user_token = nil
      @user_secret = nil
    end

    def application_credentials
      raise ArgumentError, 'application_token not set' if @application_token.nil? || @application_token.strip == ''
      raise ArgumentError, 'application_secret not set' if @application_secret.nil? || @application_secret.strip == ''
      "Basic #{::Base64.strict_encode64("#{@application_token}:#{@application_secret}")}"
    end

    def user_credentials
      raise ArgumentError, 'user_token not set' if @user_token.nil? || @user_token.strip == ''
      raise ArgumentError, 'user_secret not set' if @user_secret.nil? || @user_secret.strip == ''
      "Basic #{::Base64.strict_encode64("#{@user_token}:#{@user_secret}")}"
    end
  end

end
