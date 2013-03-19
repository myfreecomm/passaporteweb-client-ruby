# passaporteweb-client-ruby

A Ruby client for the PassaporteWeb REST API

PassaporteWeb API docs: https://app.passaporteweb.com.br/static/docs/

## Installation

Add this line to your application's Gemfile:

    gem 'passaporteweb-client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install passaporteweb-client

## Usage

### Configuration

    require 'passaporte_web'

    PassaporteWeb.configure do |c|
      c.url = 'http://sandbox.app.passaporteweb.com.br' # defaults to 'https://app.passaporteweb.com.br' if omitted
      c.application_token = 'some-app-token'
      c.application_secret = 'some-app-secret'
      c.user_token = 'some-user-token'
      c.user_secret = 'some-user-secret'
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
