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

      expect(account).to be_instance_of(described_class)
      expect(account).not_to be_persisted
      expect(account.errors).to be_empty
      expect(account.identity).to eq(identity)

      expect(account.membership_details_url).to eq('/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/5e32f927-c4ab-404e-a91c-b2abc05afb56/')
      expect(account.plan_slug).to eq('basic')
      expect(account.roles).to eq(['user', 'admin'])
      expect(account.url).to eq('/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/')
      expect(account.expiration).to eq('2014-05-01 00:00:00')
      expect(account.service_data).to eq({"name" => "Identity Client","slug" => "identity_client"})
      expect(account.account_data).to eq({"name" => "Investimentos","uuid" => "859d3542-84d6-4909-b1bd-4f43c1312065"})
      expect(account.add_member_url).to eq('/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/')
      expect(account.name).to eq('Investimentos') # TODO ???
      expect(account.uuid).to eq('859d3542-84d6-4909-b1bd-4f43c1312065') # TODO ???
    end
  end

  describe ".find_all", vcr: true do
    it "should find all service accounts the identity is associted to in the current authenticated application" do
      accounts = described_class.find_all(identity)
      expect(accounts.size).to eq(9)
      expect(accounts.map { |a| a.instance_of?(described_class) }.uniq).to eq([true])
      expect(accounts.map { |a| a.persisted? }.uniq).to eq([true])

      account = accounts[4]
      expect(account.errors).to be_empty
      expect(account.identity).to eq(identity)
      expect(account.membership_details_url).to eq('/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/5e32f927-c4ab-404e-a91c-b2abc05afb56/')
      expect(account.plan_slug).to eq('basic')
      expect(account.roles).to eq(['owner', 'foo,bar'])
      expect(account.url).to eq('/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/')
      expect(account.expiration).to eq('2014-05-01 00:00:00')
      expect(account.service_data).to eq({"name" => "Identity Client","slug" => "identity_client"})
      expect(account.account_data).to eq({"name" => "Investimentos","uuid" => "859d3542-84d6-4909-b1bd-4f43c1312065"})
      expect(account.add_member_url).to eq('/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/')
      expect(account.name).to eq('Investimentos')
      expect(account.uuid).to eq('859d3542-84d6-4909-b1bd-4f43c1312065')
    end
    it "should include expired service accounts if asked to" do
      accounts = described_class.find_all(identity, true)
      expect(accounts.size).to eq(12)
      expect(accounts.map { |a| a.expiration }.uniq).to eq([nil, "2013-04-02 00:00:00", "2014-05-01 00:00:00", "2013-04-18 00:00:00"])
    end
    it "should find only service accounts in which the identity has the supplied role" do
      role = 'foo,bar'
      accounts = described_class.find_all(identity, false, role)
      expect(accounts.size).to eq(1)
      expect(accounts.map { |a| a.roles.include?(role) }.uniq).to eq([true])
    end
    it "should include other services is asked to" do
      accounts = described_class.find_all(identity, false, nil, true)
      expect(accounts.size).to eq(9)
      expect(accounts.map { |a| a.expiration }.uniq).to eq([nil, "2014-05-01 00:00:00"])
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
        expect(account.save).to be_truthy
        expect(account).to be_persisted

        expect(account.plan_slug).to eq('basic')
        expect(account.roles).to eq(['owner'])
        expect(account.service_data).to eq({"name" => "Identity Client","slug" => "identity_client"})
        expect(account.account_data['name']).to eq('Conta Nova em Folha')
        expect(account.account_data['uuid']).not_to be_nil
        expect(account.name).to eq('Conta Nova em Folha')
        expect(account.uuid).not_to be_nil
        expect(account.url).not_to be_nil
        expect(account.membership_details_url).not_to be_nil
        expect(account.add_member_url).not_to be_nil
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
        expect(account.save).to be_truthy
        expect(account).to be_persisted

        expect(account.plan_slug).to eq('basic')
        expect(account.roles).to eq(['owner'])
        expect(account.service_data).to eq({"name" => "Identity Client","slug" => "identity_client"})
        expect(account.account_data['name']).not_to be_nil
        expect(account.account_data['uuid']).to eq(account_uuid)
        expect(account.name).not_to be_nil
        expect(account.uuid).to eq(account_uuid)
        expect(account.url).not_to be_nil
        expect(account.membership_details_url).not_to be_nil
        expect(account.add_member_url).not_to be_nil
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
        expect(account.save).to be_falsy
        expect(account).not_to be_persisted
        expect(account.errors).to eq({"field_errors"=>{"expiration"=>["Cannot set the expiration to the past."]}})
      end
    end
  end

end
