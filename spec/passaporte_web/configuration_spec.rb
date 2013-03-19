# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::Configuration do

  it "should use the production PassaporteWeb URL by default" do
    PassaporteWeb::Configuration.new.url.should == 'https://app.passaporteweb.com.br'
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
    config.user_secret.should be_nil
  end

end
