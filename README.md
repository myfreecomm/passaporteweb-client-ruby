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
      c.user_agent = 'My App v1.0' # optional, but you should pass a custom user-agent identifying your app
      c.application_token = 'some-app-token'
      c.application_secret = 'some-app-secret'
      c.user_token = 'some-user-token'
      c.user_secret = 'some-user-secret'
    end

### Profiles

    profile1 = PassaporteWeb::Profile.find("a5868d14-6529-477a-9c6b-a09dd42a7cd2")
    profile1.email # "john@example.com"
    profile1.first_name # "John"

    profile2 = PassaporteWeb::Profile.find_by_email("john@example.com")
    profile2.uuid # "a5868d14-6529-477a-9c6b-a09dd42a7cd2"

    profile1 == profile2 # true

    profile1.gender # nil
    profile1.gender = 'M'
    profile1.save # true
    profile1.gender # 'M'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
