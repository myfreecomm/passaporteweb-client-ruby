require 'simplecov'
require 'coveralls'
require 'dotenv'

Dotenv.load('.env.test')

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
  c.ignore_localhost = true
  c.default_cassette_options = { record: :new_episodes }
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  c.mock_with :rspec
  c.example_status_persistence_file_path = '.rspec_persistence'
  c.include Authorization

  c.before do
    PassaporteWeb.configure do |config|
      # https://sandbox.v2.passaporteweb.com.br/applications/89e9d504-e2a8-476e-ac94-c33e68399c7e
      # Test application - luiz.buiatte+pw.api.test@nexaas.com
      config.url = ENV['PASSAPORTE_WEB_URL']
      config.application_token = ENV['APPLICATION_TOKEN']
      config.application_secret = ENV['APPLICATION_SECRET']
    end
  end
end
