if ENV['COVERAGE'] == 'on'
  require 'simplecov'
  SimpleCov.start
  puts "required simplecov"
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'passaporte_web'

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.default_cassette_options = { :record => :once }
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  c.mock_with :rspec

  # so we can use :vcr rather than :vcr => true;
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true
end
