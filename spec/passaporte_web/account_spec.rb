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

  describe ".save_user", :vcr => true do
    describe "POST" do
      context "on success" do
        it "should save the members in account" do
          PassaporteWeb::Account.save_user("859d3542-84d6-4909-b1bd-4f43c1312065", "a5868d14-6529-477a-9c6b-a09dd42a7cd2", "user").should be_true
        end
      end
      context "on failure" do
        it "should not save the members in account without identity params" do
          expect {
            PassaporteWeb::Account.save_user("859d3542-84d6-4909-b1bd-4f43c1312062", nil)
          }.to raise_error(RuntimeError, "The identity field is required.")
        end

        it "should not save the members in account without uuid params" do
          expect {
            PassaporteWeb::Account.save_user(nil, "859d3542-84d6-4909-b1bd-4f43c1312062")
          }.to raise_error(RuntimeError, "The uuid field is required.")
        end
      end
    end
  end

  describe ".list_members", :vcr => true do
    context "on success" do
      it "should return hash with membership data" do
        list_members = PassaporteWeb::Account.list_members("859d3542-84d6-4909-b1bd-4f43c1312065", "a5868d14-6529-477a-9c6b-a09dd42a7cd2")
        list_members.should be_instance_of(Hash)
        list_members["roles"].should be_instance_of(Array)
        list_members["roles"].first.should == "user"
        list_members["identity"]["first_name"].should == "Rodrigo"
        list_members["identity"]["last_name"].should == "Tassinari"
      end
    end

    context "on failed" do
      it "should return RuntimeError with uuid param" do
        expect{
          PassaporteWeb::Account.list_members("859d3542-84d6-4909-b1bd-4f43c1312065", nil )
        }.to raise_error(RuntimeError, "The member_uuid field is required.")
      end

      it "should return RuntimeError with member_uuid param" do
        expect{
          PassaporteWeb::Account.list_members(nil, "859d3542-84d6-4909-b1bd-4f43c1312065" )
        }.to raise_error(RuntimeError, "The uuid field is required.")
      end

      it "should return RuntimeError without params" do
        expect{
          PassaporteWeb::Account.list_members
        }.to raise_error
      end
    end
  end

end