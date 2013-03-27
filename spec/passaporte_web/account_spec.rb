# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::Account do

  describe ".new" do
    it "should instanciate an empty object" do
      account = PassaporteWeb::Account.new
      account.attributes.should == {:plan_slug=>nil, :expiration=>nil, :identity=>nil, :roles=>nil, :member_uuid=>nil, :role=>nil, :include_expired_accounts=>nil, :name=>nil, :members_data=>nil, :url=>nil, :service_data=>nil, :account_data=>nil, :add_member_url=>nil}
    end
    it "should instanciate an object with attributes set" do
      attributes = {
        "plan_slug"=>"free",
        "expiration"=>"2011-12-31",
        "identity"=>"ac3540c7-5453-424d-bdfd-8ef2d9ff78df",
        "roles"=>"admin,user",
        "member_uuid"=>"ac3540c7-5453-424d-bdfd-8ef2d9ff78df",
        "role"=>"owner",
        "include_expired_accounts"=>"true",
        "name"=>"Conta Pessoa",
        "members_data" => nil,
        "url" => nil,
        "service_data" => nil,
        "account_data" => nil,
        "add_member_url" => nil
      }
      account = PassaporteWeb::Account.new(attributes)
      account.attributes.should == { :plan_slug=>"free", :expiration=>"2011-12-31", :identity=>"ac3540c7-5453-424d-bdfd-8ef2d9ff78df", :roles=>"admin,user", :member_uuid=>"ac3540c7-5453-424d-bdfd-8ef2d9ff78df", :role=>"owner", :include_expired_accounts=>"true", :name=>"Conta Pessoa", :members_data=>nil, :url=>nil, :service_data=>nil, :account_data=>nil, :add_member_url=>nil }
      account.plan_slug.should == "free"
      account.expiration.should == "2011-12-31"
      account.identity.should == "ac3540c7-5453-424d-bdfd-8ef2d9ff78df"
      account.roles.should == "admin,user"
      account.member_uuid.should == "ac3540c7-5453-424d-bdfd-8ef2d9ff78df"
      account.role.should == "owner"
      account.include_expired_accounts.should == "true"
      account.name.should == "Conta Pessoa"
    end
  end

  describe ".find_all", :vcr => true do
    context "without params" do
      it "should return Array of Hash with accounts" do
        accounts = PassaporteWeb::Account.find_all
        accounts.size.should > 1
        accounts.should be_instance_of(Array)
        accounts.last["plan_slug"].should == "free"
        accounts.last["add_member_url"].should == "/organizations/api/accounts/ddc71259-cc15-4f9c-b876-856d633771ab/members/"
      end
    end

    context "with params limit and page" do
      it "should return Array of Hash with account" do
        accounts = PassaporteWeb::Account.find_all(1,1)
        accounts.size.should == 1
        accounts.should be_instance_of(Array)
        accounts.last["plan_slug"].should == "identity-client"
        accounts.last["add_member_url"].should == "/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/"
      end
    end
  end

  describe ".find_by_uuid", :vcr => true do
    context "with param" do
      context "on success" do
        it "should return Hash with account" do
          accounts = PassaporteWeb::Account.find_by_uuid("859d3542-84d6-4909-b1bd-4f43c1312065")
          accounts.size.should == 1
          accounts.should be_instance_of(Array)
          accounts.last["plan_slug"].should == "identity-client"
          accounts.last["add_member_url"].should == "/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/"
        end
      end

      context "on failed" do
        it "should raise an error if no Account exist with that uuid" do
          expect {
            PassaporteWeb::Account.find_by_uuid("859d3542-84d6-4909-b1bd-4f43c1312062")
          }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
        end
      end
    end

    context "without param" do
      it "should return Array of Hash with accounts" do
        accounts = PassaporteWeb::Account.find_by_uuid
        accounts.size.should > 1
        accounts.should be_instance_of(Array)
        accounts.last["plan_slug"].should == "free"
        accounts.last["add_member_url"].should == "/organizations/api/accounts/ddc71259-cc15-4f9c-b876-856d633771ab/members/"
      end
    end

  end

end