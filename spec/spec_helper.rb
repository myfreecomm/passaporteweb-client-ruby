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
      #config.url = 'https://sandbox.v2.passaporteweb.com.br'
      #config.application_token = 'HOR5XXLN5VCERCPDHYL2C24AEM'
      #config.application_secret = 'QGS6B5YRNRD3TPC75VCTWOKGBQ'
      config.url = 'http://localhost:3000'
      config.application_token = 'P6LYSYEIBBCUDEUU3MN77FPIIE'
      config.application_secret = 'ROPHZ7JTVNFE5MDPNMPAK7XK7A'

      # http://localhost:3000/oauth/authorize?client_id=P6LYSYEIBBCUDEUU3MN77FPIIE&redirect_uri=https://localhost:3000/auth/passaporte_web/callback&response_type=code
      # client = PassaporteWeb::Client::OAuth.build
      #token = client.auth_code.get_token('08161c6176f9d323418c2c26c781370cc7d52f0683cf5554736fb18ee0629d58', :redirect_uri => 'https://localhost:3000/auth/passaporte_web/callback')
      # @token="1b9900529d0565f86a6a7302d148c1452eb3bacdbe31ad529c63de4ff48f149e", @refresh_token="1306fc5eb98280eb8baded5a32dbd0743af434f9ca88703090949a4ea77a37da", @expires_in=7200, @expires_at=1533743206
    end
    # TODO: sandbox values
    @user_credentials = OpenStruct.new(
      access_token: '1b9900529d0565f86a6a7302d148c1452eb3bacdbe31ad529c63de4ff48f149e',
      refresh_token: '1306fc5eb98280eb8baded5a32dbd0743af434f9ca88703090949a4ea77a37da',
      expires_in: 7200,
      expires_at: 1533743206)
  end
end
