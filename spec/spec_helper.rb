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

  c.before(:vcr => true) do
    PassaporteWeb.configure do |c|
      c.url = 'https://sandbox.v2.passaporteweb.com.br'
      # Those credentials are from Identity Client App
      c.application_token = '8ab29iwKFI'
      c.application_secret = 'VnWYenOqYsHtcFowrdJlwdJNALq5Go9v'
    end
  end
end
