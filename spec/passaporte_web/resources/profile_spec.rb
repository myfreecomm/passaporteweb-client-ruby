require "spec_helper"

describe PassaporteWeb::Resources::Profile do
  let(:client) { PassaporteWeb::Client::Identity.new(user_credentials) }
  let(:resource) { client.profile }

  describe "#get" do
    subject { resource.get }

    it 'returns the profile for the user' do
      VCR.use_cassette('identity/profile/success') do
        expect(subject).to be_a(PassaporteWeb::Entities::Profile)
        expect(subject.id).to eq('1dba9218-62f6-40bc-aebc-e965be915736')
        expect(subject.email).to eq('luiz.buiatte@nexaas.com')
        expect(subject.birth.to_s).to eq('1976-05-29')
      end
    end
  end

  describe '#profession_info' do
    subject { resource.professional_info }

    it 'returns the professional info for the user' do
       VCR.use_cassette('identity/professional_info/success') do
        expect(subject).to be_a(PassaporteWeb::Entities::Profile::ProfessionalInfo)
        expect(subject.id).to eq('1dba9218-62f6-40bc-aebc-e965be915736')
        expect(subject.company).to eq('Nexaas')
      end
    end
  end

  describe '#contacts' do
    subject { resource.contacts }

    it 'returns the contacts for the user' do
       VCR.use_cassette('identity/contacts/success') do
        expect(subject).to be_a(PassaporteWeb::Entities::Profile::Contacts)
        expect(subject.id).to eq('1dba9218-62f6-40bc-aebc-e965be915736')
        expect(subject.phone_numbers).not_to be_empty
      end
    end
  end

  describe '#contacts' do
    subject { resource.emails }

    it 'returns the contacts for the user' do
       VCR.use_cassette('identity/emails/success') do
        expect(subject).to be_a(PassaporteWeb::Entities::Profile::Emails)
        expect(subject.id).to eq('1dba9218-62f6-40bc-aebc-e965be915736')
        expect(subject.emails).not_to be_empty
      end
    end
  end
end
