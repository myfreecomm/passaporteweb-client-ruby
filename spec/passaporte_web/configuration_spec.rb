# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::Configuration do

  it "should use the production PassaporteWeb URL by default" do
    expect(PassaporteWeb::Configuration.new.url).to eq('https://app.passaporteweb.com.br')
  end

  it "should use a default user agent" do
    expect(PassaporteWeb::Configuration.new.user_agent).to eq("PassaporteWeb Ruby Client v#{PassaporteWeb::VERSION}")
  end

  it 'should allow setting the configuration parameters' do
    config = PassaporteWeb::Configuration.new

    config.url = 'http://sandbox.app.passaporteweb.com.br'
    config.application_token = 'some-app-token'
    config.application_secret = 'some-app-secret'

    expect(config.url).to eq('http://sandbox.app.passaporteweb.com.br')
    expect(config.application_token).to eq('some-app-token')
    expect(config.application_secret).to eq('some-app-secret')
    expect(config.user_token).to be_nil
  end

  describe "#application_credentials" do
    let(:config) { PassaporteWeb::Configuration.new }
    it "should return the HTTP Basic Auth header value for the application login" do
      config.application_token = 'some-app-token'
      config.application_secret = 'some-app-secret'
      expect(config.application_credentials).to eq('Basic c29tZS1hcHAtdG9rZW46c29tZS1hcHAtc2VjcmV0')
    end
    it "should require the application_token to be set" do
      config.application_secret = 'some-app-secret'
      expect { config.application_credentials }.to raise_error(ArgumentError, 'application_token not set')
    end
    it "should require the application_secret to be set" do
      config.application_token = 'some-app-token'
      expect { config.application_credentials }.to raise_error(ArgumentError, 'application_secret not set')
    end
  end

  describe "#user_credentials" do
    let(:config) { PassaporteWeb::Configuration.new }
    it "should return the HTTP Basic Auth header value for the user login" do
      config.user_token = 'some-user-token'
      expect(config.user_credentials).to eq('Basic OnNvbWUtdXNlci10b2tlbg==')
    end
    it "should require the user_token to be set" do
      expect { config.user_credentials }.to raise_error(ArgumentError, 'user_token not set')
    end
  end

end
