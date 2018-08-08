require "spec_helper"

describe PassaporteWeb::Client::Identity do
  subject { described_class.new(user_credentials) }

  describe '#profile' do
    it 'provides the profile resource' do
      VCR.use_cassette('identity/refresh_token') do
        expect(subject.profile).to be_a(PassaporteWeb::Resources::Profile)
      end
    end
  end

  describe '#sign_up' do
    it 'provides the signup resource' do
      VCR.use_cassette('identity/refresh_token') do
        expect(subject.sign_up).to be_a(PassaporteWeb::Resources::SignUp)
      end
    end
  end
end
