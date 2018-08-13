require 'spec_helper'

describe PassaporteWeb::Client::Application do
  subject { described_class.new }

  describe '#sign_up' do
    it 'provides the signup resource' do
      VCR.use_cassette('application/sign_up/client_credentials') do
        expect(subject.sign_up).to be_a(PassaporteWeb::Resources::SignUp)
      end
    end
  end
end
