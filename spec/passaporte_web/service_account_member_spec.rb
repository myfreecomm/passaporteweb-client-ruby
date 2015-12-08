# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::ServiceAccountMember do
  let(:service_account) { PassaporteWeb::ServiceAccount.find('859d3542-84d6-4909-b1bd-4f43c1312065') }
  let(:identity) { PassaporteWeb::Identity.find('5e32f927-c4ab-404e-a91c-b2abc05afb56') }

  let(:mock_service_account) { double('ServiceAccount', uuid: 'service-account-uuid') }
  let(:mock_identity) { double('Identity', uuid: 'identity-uuid') }

  describe ".new" do
    it "should instanciate a minumum object" do
      member = described_class.new(mock_service_account, mock_identity)
      expect(member.service_account).to eq(mock_service_account)
      expect(member.identity).to eq(mock_identity)
      expect(member.roles).to eq(['user'])
      expect(member.membership_details_url).to be_nil
      expect(member.errors).to be_empty
      expect(member).not_to be_persisted
      expect(member).not_to be_destroyed
    end
    it "should instanciate an object with attributes set" do
      member = described_class.new(mock_service_account, mock_identity, ['admin', 'user'])
      expect(member.roles).to eq(['admin', 'user'])
    end
  end

  describe ".find", vcr: true do
    it "should return an instance of ServiceAccountMember with all attributes set" do
      member = described_class.find(service_account, identity)
      expect(member.service_account).to eq(service_account)
      expect(member.identity).to eq(identity)
      expect(member.roles).to eq(['admin','user'])
      expect(member.membership_details_url).to eq("/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/5e32f927-c4ab-404e-a91c-b2abc05afb56/")
      expect(member.errors).to be_empty
      expect(member).to be_persisted
      expect(member).not_to be_destroyed
    end
    it "should raise an 404 error if the membership does not exist" do
      expect {
        described_class.find(service_account, double('Identity', uuid: 'identity-uuid'))
      }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
    end
  end

  describe "#destroy", vcr: true do
    it "should destroy the membership, removing the association between service_account and identity" do
      member = described_class.find(service_account, identity)
      expect(member.destroy).to be_truthy
      expect(member).not_to be_persisted
      expect(member).to be_destroyed
      expect(member.errors).to be_empty
      expect {
        described_class.find(service_account, identity)
      }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
    end
    it "should return false if the role is owner" do
      member = described_class.find(service_account, identity)
      expect(member.roles).to include('owner')
      expect(member.destroy).to be_falsy
      expect(member).to be_persisted
      expect(member).not_to be_destroyed
      expect(member.errors).to eq("Service owner cannot be removed from members list")

      expect {
        described_class.find(service_account, identity)
      }.not_to raise_error
    end
  end

  describe "#save", vcr: true do
    context "when creating" do
      let(:member) { described_class.new(service_account, identity, ['admin','user']) }
      context "on success" do
        it "should create the membership between the service_account and the identity" do
          expect(member.save).to be_truthy
          expect(member.service_account).to eq(service_account)
          expect(member.identity).to eq(identity)
          expect(member.roles).to eq(['admin','user'])
          expect(member.membership_details_url).to eq("/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/5e32f927-c4ab-404e-a91c-b2abc05afb56/")
          expect(member.errors).to be_empty
          expect(member).to be_persisted
          expect(member).not_to be_destroyed

          member = described_class.find(service_account, identity)
          expect(member.service_account).to eq(service_account)
          expect(member.identity).to eq(identity)
          expect(member.roles).to eq(['admin','user'])
          expect(member.membership_details_url).to eq("/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/5e32f927-c4ab-404e-a91c-b2abc05afb56/")
          expect(member.errors).to be_empty
          expect(member).to be_persisted
          expect(member).not_to be_destroyed
        end
      end
      context "on failure" do
        it "should not create the membership and set the errors on the object" do
          member.roles = ['owner'] # can't create membership for the owner
          expect(member.save).to be_falsy
          expect(member.errors).to eq("Adding a member as owner is not allowed")
          expect(member).not_to be_persisted
          expect(member).not_to be_destroyed

          expect {
            described_class.find(service_account, identity)
          }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
        end
        it "should return false if the membership already exists" do
          expect(member.save).to be_falsy
          expect(member.errors).to eq("Identity with uuid=5e32f927-c4ab-404e-a91c-b2abc05afb56 is already in members list of service identity_client at account 859d3542-84d6-4909-b1bd-4f43c1312065")
          expect(member).not_to be_persisted
          expect(member).not_to be_destroyed

          expect {
            described_class.find(service_account, identity)
          }.not_to raise_error
        end
      end
    end
    context "when updating" do
      let(:member) { described_class.find(service_account, identity) }
      context "on success" do
        it "should update the member roles" do
          expect(member.roles).to eq(['admin', 'user'])
          member.roles = ['user']
          expect(member.save).to be_truthy
          expect(member.errors).to be_empty
          expect(member.roles).to eq(['user'])

          member = described_class.find(service_account, identity)
          expect(member.roles).to eq(['user'])
        end
      end
      context "on failure" do
        it "should return false and set the errors" do
          pending "está deixando setar como owner e não deixa setar sem nenhum role, como fazer?"
          expect(member.roles).to eq(['admin', 'user'])
          member.roles = ['owner']
          expect(member.save).to be_falsy
          expect(member.errors).not_to be_empty
          expect(member.roles).to eq(['owner'])

          member = described_class.find(service_account, identity)
          expect(member.roles).to eq(['admin', 'user'])
        end
      end
    end
  end

end
