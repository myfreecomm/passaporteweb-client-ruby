# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::Configuration do

  it "should use the production PassaporteWeb URL by default" do
    PassaporteWeb::Configuration.new.url.should == 'https://app.passaporteweb.com.br'
  end

  it "should use a default user agent" do
    PassaporteWeb::Configuration.new.user_agent.should == "PassaporteWeb Ruby Client v#{PassaporteWeb::VERSION}"
  end

  it 'should allow setting the configuration parameters' do
    config = PassaporteWeb::Configuration.new

    config.url = 'http://sandbox.app.passaporteweb.com.br'
    config.application_token = 'some-app-token'
    config.application_secret = 'some-app-secret'

    config.url.should == 'http://sandbox.app.passaporteweb.com.br'
    config.application_token.should == 'some-app-token'
    config.application_secret.should == 'some-app-secret'
    config.user_token.should be_nil
  end

  describe "#application_credentials" do
    let(:config) { PassaporteWeb::Configuration.new }
    it "should return the HTTP Basic Auth header value for the application login" do
      config.application_token = 'some-app-token'
      config.application_secret = 'some-app-secret'
      config.application_credentials.should == 'Basic c29tZS1hcHAtdG9rZW46c29tZS1hcHAtc2VjcmV0'
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
      config.user_credentials.should == 'Basic OnNvbWUtdXNlci10b2tlbg=='
    end
    it "should require the user_token to be set" do
      expect { config.user_credentials }.to raise_error(ArgumentError, 'user_token not set')
    end
  end

end
