# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::IdentityServiceAccount do
  let(:identity) { PassaporteWeb::Identity.find('5e32f927-c4ab-404e-a91c-b2abc05afb56') }

  describe ".new", vcr: true do
    it "should instanciate a new object with attributes set" do
      attributes = {
        plan_slug: 'basic',
        roles: ['user', 'admin'],
        expiration: '2014-05-01 00:00:00',
        url: '/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/',
        membership_details_url: '/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/5e32f927-c4ab-404e-a91c-b2abc05afb56/',
        add_member_url: '/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/',
        service_data: {"name" => "Identity Client","slug" => "identity_client"},
        account_data: {"name" => "Investimentos","uuid" => "859d3542-84d6-4909-b1bd-4f43c1312065"},
        name: 'Investimentos',
        uuid: '859d3542-84d6-4909-b1bd-4f43c1312065'
      }
      account = described_class.new(identity, attributes)

      account.should be_instance_of(described_class)
      account.should_not be_persisted
      account.errors.should be_empty
      account.identity.should == identity

      account.membership_details_url.should == '/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/5e32f927-c4ab-404e-a91c-b2abc05afb56/'
      account.plan_slug.should == 'basic'
      account.roles.should == ['user', 'admin']
      account.url.should == '/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/'
      account.expiration.should == '2014-05-01 00:00:00'
      account.service_data.should == {"name" => "Identity Client","slug" => "identity_client"}
      account.account_data.should == {"name" => "Investimentos","uuid" => "859d3542-84d6-4909-b1bd-4f43c1312065"}
      account.add_member_url.should == '/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/'
      account.name.should == 'Investimentos' # TODO ???
      account.uuid.should == '859d3542-84d6-4909-b1bd-4f43c1312065' # TODO ???
    end
  end

  describe ".find_all", vcr: true do
    it "should find all service accounts the identity is associted to in the current authenticated application" do
      accounts = described_class.find_all(identity)
      accounts.size.should == 9
      accounts.map { |a| a.instance_of?(described_class) }.uniq.should == [true]
      accounts.map { |a| a.persisted? }.uniq.should == [true]

      account = accounts[4]
      account.errors.should be_empty
      account.identity.should == identity
      account.membership_details_url.should == '/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/5e32f927-c4ab-404e-a91c-b2abc05afb56/'
      account.plan_slug.should == 'basic'
      account.roles.should == ['owner', 'foo,bar']
      account.url.should == '/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/'
      account.expiration.should == '2014-05-01 00:00:00'
      account.service_data.should == {"name" => "Identity Client","slug" => "identity_client"}
      account.account_data.should == {"name" => "Investimentos","uuid" => "859d3542-84d6-4909-b1bd-4f43c1312065"}
      account.add_member_url.should == '/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/'
      account.name.should == 'Investimentos'
      account.uuid.should == '859d3542-84d6-4909-b1bd-4f43c1312065'
    end
    it "should include expired service accounts if asked to" do
      accounts = described_class.find_all(identity, true)
      accounts.size.should == 12
      accounts.map { |a| a.expiration }.uniq.should == [nil, "2013-04-02 00:00:00", "2014-05-01 00:00:00", "2013-04-18 00:00:00"]
    end
    it "should find only service accounts in which the identity has the supplied role" do
      role = 'foo,bar'
      accounts = described_class.find_all(identity, false, role)
      accounts.size.should == 1
      accounts.map { |a| a.roles.include?(role) }.uniq.should == [true]
    end
    it "should include other services is asked to" do
      accounts = described_class.find_all(identity, false, nil, true)
      accounts.size.should == 9
      accounts.map { |a| a.expiration }.uniq.should == [nil, "2014-05-01 00:00:00"]
    end
  end

  describe "#save", vcr: true do
    context "on success" do
      it "should create a new service account by name for the identity in the current authenticated application" do
        expiration_date = (Time.now + (15 * 60 * 60 * 24)).strftime('%Y-%m-%d')
        attributes = {
          plan_slug: 'basic',
          expiration: expiration_date,
          name: 'Conta Nova em Folha'
        }
        account = described_class.new(identity, attributes)
        account.save.should be_true
        account.should be_persisted

        account.plan_slug.should == 'basic'
        account.roles.should == ['owner']
        account.service_data.should == {"name" => "Identity Client","slug" => "identity_client"}
        account.account_data['name'].should == 'Conta Nova em Folha'
        account.account_data['uuid'].should_not be_nil
        account.name.should == 'Conta Nova em Folha'
        account.uuid.should_not be_nil
        account.url.should_not be_nil
        account.membership_details_url.should_not be_nil
        account.add_member_url.should_not be_nil
      end
      it "should create a new service account by uuid for the identity in the current authenticated application" do
        pending 'pegar explicação com Vitor'
        account_uuid = '92d52d25-c7a6-4d16-ae9e-c5f2b4f8fa43'
        expiration_date = (Time.now + (15 * 60 * 60 * 24)).strftime('%Y-%m-%d')
        attributes = {
          plan_slug: 'basic',
          expiration: expiration_date,
          uuid: account_uuid
        }
        account = described_class.new(identity, attributes)
        account.save.should be_true
        account.should be_persisted

        account.plan_slug.should == 'basic'
        account.roles.should == ['owner']
        account.service_data.should == {"name" => "Identity Client","slug" => "identity_client"}
        account.account_data['name'].should_not be_nil
        account.account_data['uuid'].should == account_uuid
        account.name.should_not be_nil
        account.uuid.should == account_uuid
        account.url.should_not be_nil
        account.membership_details_url.should_not be_nil
        account.add_member_url.should_not be_nil
      end
    end
    context "on failure" do
      it "should return false and populate #errors with the failure reasons" do
        expiration_date = (Time.now - (15 * 60 * 60 * 24)).strftime('%Y-%m-%d')
        attributes = {
          plan_slug: 'basic',
          expiration: expiration_date,
          name: 'Conta Nova em Folha 2: A missão'
        }
        account = described_class.new(identity, attributes)
        account.save.should be_false
        account.should_not be_persisted
        account.errors.should == {"field_errors"=>{"expiration"=>["Cannot set the expiration to the past."]}}
      end
    end
  end

end
