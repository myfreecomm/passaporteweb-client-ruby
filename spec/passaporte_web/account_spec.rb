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
    let(:mock_response) { mock('response', body: [].to_json, code: 200) }
    it "should find all accounts related to the authenticated application and return them as an array of Account instances" do
      accounts = PassaporteWeb::Account.find_all
      accounts.should be_instance_of(Array)
      accounts.size.should == 12
      accounts.map { |a| a.instance_of?(PassaporteWeb::Account) }.uniq.should == [true]
      accounts.map(&:plan_slug).uniq.sort.should == ['free', 'passaporteweb-client-ruby']
    end
    it "should ask for page 1 and 20 accounts per page by default" do
      PassaporteWeb::Http.should_receive(:get).with("/organizations/api/accounts/?page=1&limit=20").and_return(mock_response)
      PassaporteWeb::Account.find_all.should == []
    end
    it "should ask for page and accounts per page as supplied" do
      PassaporteWeb::Http.should_receive(:get).with("/organizations/api/accounts/?page=4&limit=100").and_return(mock_response)
      PassaporteWeb::Account.find_all(4, 100).should == []
    end
    it "should raise an error if the page does not exist" do
      expect {
        PassaporteWeb::Account.find_all(4_000_000)
      }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
    end
  end

  describe ".find", :vcr => true do
    context "on success" do
      it "should return an instance of Account with all the details" do
        account = PassaporteWeb::Account.find("859d3542-84d6-4909-b1bd-4f43c1312065")
        account.should be_instance_of(PassaporteWeb::Account)
        account.plan_slug.should == "free"
        account.account_data.should == {"name" => "Investimentos", "uuid" => "859d3542-84d6-4909-b1bd-4f43c1312065"}
        account.service_data.should == {"name" => "Identity Client", "slug" => "identity_client"}
        account.members_data.should == [
          {"membership_details_url"=>"/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/20a8bbe1-3b4a-4e46-a69a-a7c524bd2ab8/", "identity"=>"20a8bbe1-3b4a-4e46-a69a-a7c524bd2ab8", "roles"=>["owner"]},
          {"membership_details_url"=>"/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/5e32f927-c4ab-404e-a91c-b2abc05afb56/", "identity"=>"5e32f927-c4ab-404e-a91c-b2abc05afb56", "roles"=>["user"]}
        ]
        account.expiration.should be_nil
        account.url.should == "/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/"
        account.add_member_url.should == "/organizations/api/accounts/859d3542-84d6-4909-b1bd-4f43c1312065/members/"
      end
    end
    context "on failure" do
      it "should raise an error if no Account exist with that uuid" do
        expect {
          PassaporteWeb::Account.find("859d3542-84d6-4909-b1bd-4f43c1312062")
        }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
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

  describe ".update_roles_members", :vcr => true do
    context "on success" do
      it "should update and return hash with membership data" do
        members = PassaporteWeb::Account.update_roles_members("859d3542-84d6-4909-b1bd-4f43c1312065", "a5868d14-6529-477a-9c6b-a09dd42a7cd2", "admin, user")
        members.should be_instance_of(Hash)
        members["roles"].should be_instance_of(Array)
        members["roles"].first.should == "admin, user"
        members["identity"]["first_name"].should == "Rodrigo"
        members["identity"]["last_name"].should == "Tassinari"
      end
    end

    context "on failed" do
      it "should return RuntimeError with uuid param" do
        expect{
          PassaporteWeb::Account.update_roles_members("859d3542-84d6-4909-b1bd-4f43c1312065", nil )
        }.to raise_error(RuntimeError, "The member_uuid field is required.")
      end

      it "should return RuntimeError with member_uuid param" do
        expect{
          PassaporteWeb::Account.update_roles_members(nil, "859d3542-84d6-4909-b1bd-4f43c1312065" )
        }.to raise_error(RuntimeError, "The uuid field is required.")
      end

      it "should return RuntimeError without params" do
        expect{
          PassaporteWeb::Account.update_roles_members
        }.to raise_error
      end
    end
  end

  describe ".delete_membership", :vcr => true do
    context "on success" do
      it "should update and return hash with membership data" do
        PassaporteWeb::Account.delete_membership("859d3542-84d6-4909-b1bd-4f43c1312065", "a5868d14-6529-477a-9c6b-a09dd42a7cd2").should be_true
      end
    end

    context "on failed" do
      it "should return RuntimeError with uuid param" do
        expect{
          PassaporteWeb::Account.delete_membership("859d3542-84d6-4909-b1bd-4f43c1312065", nil )
        }.to raise_error(RuntimeError, "The member_uuid field is required.")
      end

      it "should return RuntimeError with member_uuid param" do
        expect{
          PassaporteWeb::Account.delete_membership(nil, "859d3542-84d6-4909-b1bd-4f43c1312065" )
        }.to raise_error(RuntimeError, "The uuid field is required.")
      end

      it "should return RuntimeError without params" do
        expect{
          PassaporteWeb::Account.delete_membership
        }.to raise_error
      end
    end
  end

   describe ".list_accounts_user", :vcr => true do
    context "on success" do
      it "should listed and return hash with data of account user" do
        list_accounts = PassaporteWeb::Account.list_accounts_user("5e32f927-c4ab-404e-a91c-b2abc05afb56")
        list_accounts.should be_instance_of(Array)
        list_accounts.first["roles"].should be_instance_of(Array)
        list_accounts.first["roles"].first.should == "user"
      end
    end

    context "on failed" do
      it "should return RuntimeError without params" do
        expect{
          PassaporteWeb::Account.list_accounts_user
        }.to raise_error(RuntimeError, "The uuid field is required.")
      end
    end
  end

  describe ".new_account_user", :vcr => true do
    describe "POST" do
      context "on success" do
        it "should save the members in account" do
          PassaporteWeb::Account.new_account_user("5e32f927-c4ab-404e-a91c-b2abc05afb56", nil, "ContaPessoal4").should be_true
        end
      end
      context "on failure" do
        it "should not save the members in account without identity params" do
          expect {
            PassaporteWeb::Account.new_account_user("859d3542-84d6-4909-b1bd-4f43c1312062")
          }.to raise_error(RuntimeError, "The fields uuid_user and name are required.")
        end

        it "should not save the members in account without uuid params" do
          expect {
            PassaporteWeb::Account.new_account_user(nil)
          }.to raise_error(RuntimeError, "The uuid field is required.")
        end
      end
    end
  end

end
