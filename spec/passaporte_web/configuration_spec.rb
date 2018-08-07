# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::Configuration do

  it "should use the production PassaporteWeb URL by default" do
    expect(PassaporteWeb::Configuration.new.url).to eq('https://v2.passaporteweb.com.br')
  end

  it "should use a default user agent" do
    expect(PassaporteWeb::Configuration.new.user_agent).to eq("PassaporteWeb Ruby Client v#{PassaporteWeb::VERSION}")
  end

  it 'should allow setting the configuration parameters' do
    config = PassaporteWeb::Configuration.new

    config.url = 'http://sandbox.v2.passaporteweb.com.br'
    config.application_id = '58ca7acc-9479-4671-8b7c-745c5a65ce08'
    config.application_secret = '8da0d1a5-961d-461f-8ae6-1922db172340'

    expect(config.url).to eq('http://sandbox.v2.passaporteweb.com.br')
    expect(config.application_id).to eq('58ca7acc-9479-4671-8b7c-745c5a65ce08')
    expect(config.application_secret).to eq('8da0d1a5-961d-461f-8ae6-1922db172340')
  end

  describe '#url_for' do
    let(:configuration) { described_class.new }

    it 'generates an URL to a resource' do
      expect(configuration.url_for('/api/v1/profile')).to eq('https://v2.passaporteweb.com.br/api/v1/profile')

      configuration.url = 'https://sandbox.v2.passaporteweb.com.br/'
      expect(configuration.url_for('/api/v1/profile'))
        .to eq('https://sandbox.v2.passaporteweb.com.br/api/v1/profile')
    end
  end

end
