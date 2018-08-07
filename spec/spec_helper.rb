require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'passaporte_web'

require 'vcr'
require 'pry'
require 'webmock/rspec'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.default_cassette_options = { :record => :once }
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  c.mock_with :rspec
  c.example_status_persistence_file_path = '.rspec_persistence'

  c.before do
    PassaporteWeb.configure do |config|
      config.url = 'https://sandbox.v2.passaporteweb.com.br'
      config.application_token = 'HOR5XXLN5VCERCPDHYL2C24AEM'
      config.application_secret = 'QGS6B5YRNRD3TPC75VCTWOKGBQ'
      #0db7d4569b9a3b248f0bf3b19bea775afdc2ccdbda935e1fc1087c15823d8574
      #token = client.auth_code.get_token('0db7d4569b9a3b248f0bf3b19bea775afdc2ccdbda935e1fc1087c15823d8574', :redirect_uri => 'https://contabilone.com.br/auth/passaporte_web/callback')
    end
  end
end
