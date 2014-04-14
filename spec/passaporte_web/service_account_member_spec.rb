# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::ServiceAccountMember do
  let(:service_account) { PassaporteWeb::ServiceAccount.find('859d3542-84d6-4909-b1bd-4f43c1312065') }
  let(:identity) { PassaporteWeb::Identity.find('5e32f927-c4ab-404e-a91c-b2abc05afb56') }

  let(:mock_service_account) { mock('ServiceAccount', uuid: 'service-account-uuid') }
  let(:mock_identity) { mock('Identity', uuid: 'identity-uuid') }

  describe ".new" do
    it "should instanciate a minumum object" do
      member = described_class.new(mock_service_account, mock_identity)
      member.service_account.should == mock_service_account
      member.identity.should == mock_identity
      member.roles.should == ['user']
      member.membership_details_url.should be_nil
      member.errors.should be_empty
      member.should_not be_persisted
      member.should_not be_destroyed
    end
    it "should instanciate an object with attributes set" do
      member = described_class.new(mock_service_account, mock_identity, ['admin', 'user'])
      member.roles.should == ['admin', 'user']
    end
  end

  describe ".find", vcr: true do
    it "should return an instance of ServiceAccountMember with all attributes set" do
      member = described_class.find(service_account, identity)
      member.service_account.should == service_account
      member.identity.should == identity
      member.roles.should == ['admin','user']
      member.membership_details_url.should == "/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/5e32f927-c4ab-404e-a91c-b2abc05afb56/"
      member.errors.should be_empty
      member.should be_persisted
      member.should_not be_destroyed
    end
    it "should raise an 404 error if the membership does not exist" do
      expect {
        described_class.find(service_account, mock('Identity', uuid: 'identity-uuid'))
      }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
    end
  end

  describe "#destroy", vcr: true do
    it "should destroy the membership, removing the association between service_account and identity" do
      member = described_class.find(service_account, identity)
      member.destroy.should be_true
      member.should_not be_persisted
      member.should be_destroyed
      member.errors.should be_empty
      expect {
        described_class.find(service_account, identity)
      }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
    end
    it "should return false if the role is owner" do
      member = described_class.find(service_account, identity)
      member.roles.should include('owner')
      member.destroy.should be_false
      member.should be_persisted
      member.should_not be_destroyed
      member.errors.should == "Service owner cannot be removed from members list"

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
          member.save.should be_true
          member.service_account.should == service_account
          member.identity.should == identity
          member.roles.should == ['admin','user']
          member.membership_details_url.should == "/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/5e32f927-c4ab-404e-a91c-b2abc05afb56/"
          member.errors.should be_empty
          member.should be_persisted
          member.should_not be_destroyed

          member = described_class.find(service_account, identity)
          member.service_account.should == service_account
          member.identity.should == identity
          member.roles.should == ['admin','user']
          member.membership_details_url.should == "/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/5e32f927-c4ab-404e-a91c-b2abc05afb56/"
          member.errors.should be_empty
          member.should be_persisted
          member.should_not be_destroyed
        end
      end
      context "on failure" do
        it "should not create the membership and set the errors on the object" do
          member.roles = ['owner'] # can't create membership for the owner
          member.save.should be_false
          member.errors.should == "Adding a member as owner is not allowed"
          member.should_not be_persisted
          member.should_not be_destroyed

          expect {
            described_class.find(service_account, identity)
          }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
        end
        it "should return false if the membership already exists" do
          member.save.should be_false
          member.errors.should == "Identity with uuid=5e32f927-c4ab-404e-a91c-b2abc05afb56 is already in members list of service identity_client at account 859d3542-84d6-4909-b1bd-4f43c1312065"
          member.should_not be_persisted
          member.should_not be_destroyed

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
          member.roles.should == ['admin', 'user']
          member.roles = ['user']
          member.save.should be_true
          member.errors.should be_empty
          member.roles.should == ['user']

          member = described_class.find(service_account, identity)
          member.roles.should == ['user']
        end
      end
      context "on failure" do
        it "should return false and set the errors" do
          pending "está deixando setar como owner e não deixa setar sem nenhum role, como fazer?"
          member.roles.should == ['admin', 'user']
          member.roles = ['owner']
          member.save.should be_false
          member.errors.should_not be_empty
          member.roles.should == ['owner']

          member = described_class.find(service_account, identity)
          member.roles.should == ['admin', 'user']
        end
      end
    end
  end

end
