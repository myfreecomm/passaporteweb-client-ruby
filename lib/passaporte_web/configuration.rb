# encoding: utf-8
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
  end

end
