require "spec_helper"

describe PassaporteWeb::Client::Identity do
  let(:credentials) do
    OpenStruct.new(
      access_token: 'd4716d6b8ec62d7de27d768042e76f389eca19146bf81c1449a824f85fe9e6a8',
      refresh_token: 'd4716d6b8ec62d7de27d768042e76f389eca19146bf81c1449a824f85fe9e6a8',
      expires_in: 7200,
      expires_at: 1533685159)
  end

  subject { described_class.new(credentials) }

  describe '#profile' do
    it 'returns the profile resource' do
      VCR.use_cassette("identity/profile/success") do
        profile = subject.profile.get
        expect(profile.email).to eq('luiz.buiatte@nexaas.com')
      end
    end
  end
end
