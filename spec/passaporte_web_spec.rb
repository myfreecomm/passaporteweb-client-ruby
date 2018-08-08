# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb do

  it 'should have a version number' do
    expect(PassaporteWeb::VERSION).not_to be_nil
  end

  describe 'configuration' do
    it 'should be done via block initialization' do
      PassaporteWeb.configure do |c|
        c.url = 'http://some/where'
        c.user_agent = 'My App v1.0'
        c.application_token = 'some-app-token'
        c.application_secret = 'some-app-secret'
      end
      expect(PassaporteWeb.configuration.url).to eq('http://some/where')
      expect(PassaporteWeb.configuration.user_agent).to eq('My App v1.0')
      expect(PassaporteWeb.configuration.application_token).to eq('some-app-token')
      expect(PassaporteWeb.configuration.application_secret).to eq('some-app-secret')
    end
    it 'should use a singleton object for the configuration values' do
      config1 = PassaporteWeb.configuration
      config2 = PassaporteWeb.configuration
      expect(config1).to be === config2
    end
  end

end
