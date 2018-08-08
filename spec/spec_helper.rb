require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'passaporte_web'

require 'vcr'
require 'pry'
require 'webmock/rspec'
require 'support/authorization'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_localhost = false
  c.default_cassette_options = { :record => :once }
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  c.mock_with :rspec
  c.example_status_persistence_file_path = '.rspec_persistence'
  c.include Authorization

  c.before do
    PassaporteWeb.configure do |config|
      #config.url = 'https://sandbox.v2.passaporteweb.com.br'
      #config.application_token = 'HOR5XXLN5VCERCPDHYL2C24AEM'
      #config.application_secret = 'QGS6B5YRNRD3TPC75VCTWOKGBQ'
      config.url = 'http://localhost:3000'
      config.application_token = 'P6LYSYEIBBCUDEUU3MN77FPIIE'
      config.application_secret = 'ROPHZ7JTVNFE5MDPNMPAK7XK7A'
    end
  end
end
