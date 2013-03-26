# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::Identity do

  describe ".new" do
    it "should instanciate an empty object" do
      identity = PassaporteWeb::Identity.new
      identity.attributes.should == {:accounts=>nil, :birth_date=>nil, :country=>nil, :cpf=>nil, :email=>nil, :first_name=>nil, :gender=>nil, :is_active=>nil, :language=>nil, :last_name=>nil, :nickname=>nil, :notifications=>nil, :send_myfreecomm_news=>nil, :send_partner_news=>nil, :services=>nil, :timezone=>nil, :update_info_url=>nil, :uuid=>nil, :password=>nil, :password2=>nil, :must_change_password=>nil, :inhibit_activation_message=>nil, :tos=>nil}
    end
    it "should instanciate an object with attributes set" do
      attributes = {
        "last_name" => "da Silva",
        "is_active" => true,
        "timezone" => "GMT-3",
        "nickname" => "Lula",
        "first_name" => "Luis Inácio",
        "send_partner_news" => false,
        "uuid" => "a5868d14-6529-477a-9c6b-a09dd42a7cd2",
        "language" => "pt_BR",
        "country" => "Brasil",
        "update_info_url" => "/profile/api/info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/",
        "send_myfreecomm_news" => false,
        "gender" => "M",
        "birth_date" => "1945-10-27",
        "email" => "lula@example.com",
        "notifications" => {
          "count" => 0,
          "list" => "/notifications/api/"
        },
        "accounts" => [],
        "services" => {
          "myfinance" => "/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/myfinance/",
          "account_manager" => "/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/account_manager/"
        },
        "password"=>nil,
        "password2"=>nil,
        "must_change_password"=>nil,
        "inhibit_activation_message"=>nil,
        "tos"=>nil
      }
      identity = PassaporteWeb::Identity.new(attributes)
      identity.attributes.should == {:accounts=>[], :birth_date=>"1945-10-27", :country=>"Brasil", :cpf=>nil, :email=>"lula@example.com", :first_name=>"Luis Inácio", :gender=>"M", :is_active=>true, :language=>"pt_BR", :last_name=>"da Silva", :nickname=>"Lula", :notifications=>{"count"=>0, "list"=>"/notifications/api/"}, :send_myfreecomm_news=>false, :send_partner_news=>false, :services=>{"myfinance"=>"/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/myfinance/", "account_manager"=>"/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/account_manager/"}, :timezone=>"GMT-3", :update_info_url=>"/profile/api/info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/", :uuid=>"a5868d14-6529-477a-9c6b-a09dd42a7cd2", :password=>nil, :password2=>nil, :must_change_password=>nil, :inhibit_activation_message=>nil, :tos=>nil}
      identity.last_name.should == "da Silva"
      identity.is_active.should == true
      identity.timezone.should == "GMT-3"
      identity.nickname.should == "Lula"
      identity.first_name.should == "Luis Inácio"
      identity.send_partner_news.should == false
      identity.uuid.should == "a5868d14-6529-477a-9c6b-a09dd42a7cd2"
      identity.language.should == "pt_BR"
      identity.country.should == "Brasil"
      identity.update_info_url.should == "/profile/api/info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/"
      identity.send_myfreecomm_news.should == false
      identity.gender.should == "M"
      identity.birth_date.should == "1945-10-27"
      identity.email.should == "lula@example.com"
      identity.notifications.should == {"count" => 0, "list" => "/notifications/api/"}
      identity.accounts.should == []
      identity.services.should == {"myfinance" => "/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/myfinance/", "account_manager" => "/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/account_manager/"}
      identity.password.should be_nil
      identity.password2.should be_nil
      identity.must_change_password.should be_nil
      identity.inhibit_activation_message.should be_nil
      identity.tos.should be_nil
    end
  end

  describe "#== and #===" do
    it "should identify two profiles with the same uuid as equal" do
      p1 = PassaporteWeb::Identity.new('uuid' => 'some-uuid')
      p2 = PassaporteWeb::Identity.new('uuid' => 'some-uuid')
      p1.should == p2
      p1.should_not === p2
      p2.should == p1
      p2.should_not === p1
    end
    it "should identify two profiles with different uuids as different" do
      p1 = PassaporteWeb::Identity.new('uuid' => 'some-uuid-1')
      p2 = PassaporteWeb::Identity.new('uuid' => 'some-uuid-2')
      p1.should_not == p2
      p1.should_not === p2
      p2.should_not == p1
      p2.should_not === p1
      p3 = PassaporteWeb::Identity.new
      p1.should_not == p3
      p3.should_not == p1
      p3.should_not === p1
    end
  end

  describe ".find", :vcr => true do
    it "should find the requested profile by uuid" do
      identity = PassaporteWeb::Identity.find("5e32f927-c4ab-404e-a91c-b2abc05afb56")
      identity.should be_instance_of(PassaporteWeb::Identity)
      identity.uuid.should == '5e32f927-c4ab-404e-a91c-b2abc05afb56'
      identity.email.should == 'teste@teste.com'
      identity.update_info_url.should == '/profile/api/info/5e32f927-c4ab-404e-a91c-b2abc05afb56/'
    end
    it "should raise an error if no profiles exist with that uuid" do
      expect {
        PassaporteWeb::Identity.find("invalid-uuid")
      }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
    end
  end

  describe ".find_by_email", :vcr => true do
    it "should find the requested profile by email" do
      identity = PassaporteWeb::Identity.find_by_email("teste@teste.com")
      identity.should be_instance_of(PassaporteWeb::Identity)
      identity.uuid.should == '5e32f927-c4ab-404e-a91c-b2abc05afb56'
      identity.email.should == 'teste@teste.com'
      identity.update_info_url.should == '/profile/api/info/5e32f927-c4ab-404e-a91c-b2abc05afb56/'
    end
    it "should raise an error if no profiles exist with that email" do
      expect {
        PassaporteWeb::Identity.find("invalid@email.com")
      }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
    end
  end

  describe ".find_by_email", :vcr => true do
    it "should find the requested profile by email" do
      identity = PassaporteWeb::Identity.find_by_email("teste@teste.com")
      identity.should be_instance_of(PassaporteWeb::Identity)
      identity.uuid.should == '5e32f927-c4ab-404e-a91c-b2abc05afb56'
      identity.email.should == 'teste@teste.com'
      identity.update_info_url.should == '/profile/api/info/5e32f927-c4ab-404e-a91c-b2abc05afb56/'
    end
    it "should raise an error if no profiles exist with that email" do
      expect {
        PassaporteWeb::Identity.find("invalid@email.com")
      }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
    end
  end

  describe "#save", :vcr => true do
    describe "PUT" do
      let(:identity) { PassaporteWeb::Identity.find("5e32f927-c4ab-404e-a91c-b2abc05afb56") }
      context "on success" do
        it "should update the profile attributes on the server" do
          identity.first_name.should == 'Testeiro'
          identity.first_name = 'Testador'
          identity.save.should be_true
          identity.first_name.should == 'Testador'

          identity = PassaporteWeb::Identity.find("5e32f927-c4ab-404e-a91c-b2abc05afb56")
          identity.first_name.should == 'Testador'
        end
      end
      context "on failure" do
        it "should return false and set the errors hash" do
          identity.cpf = 42
          identity.save.should be_false
          identity.errors.should == {"cpf" => ["Certifique-se de que o valor tenha no mínimo 11 caracteres (ele possui 2)."]}
        end
      end
    end

    describe "POST" do
      context "on success" do
        it "should save with password, password2 and must_change_password" do
          attributes = {
            "email" => "lula_luis46@example.com",
            "first_name" => "Luis Inácio",
            "last_name" => "da Silva",
            "password" => "rW5oHxYB",
            "password2" => "rW5oHxYB",
            "must_change_password" => true,
            "tos" => true
          }
          identity = PassaporteWeb::Identity.new(attributes)
          identity.save.should be_true
        end

        it "should sabe with all params" do
          attributes = {
            "email" => "lula_luis75@example.com",
            "first_name" => "Luis Inácio",
            "last_name" => "da Silva",
            "password" => "rW5oHxYB",
            "password2" => "rW5oHxYB",
            "must_change_password" => true,
            "tos" => true,
            "inhibit_activation_message" => false,
            "cpf" => "545.334.276-50",
            "send_partner_news" => false,
            "send_myfreecomm_news" => false
          }
          identity = PassaporteWeb::Identity.new(attributes)
          identity.save.should be_true
        end
      end

      context "on failure" do
        it "should save without password, password2 and must_change_password" do
          attributes = {
            "email" => "lula_luis81@example.com",
            "first_name" => "Luis Inácio",
            "last_name" => "da Silva",
            "tos" => true
          }
          identity = PassaporteWeb::Identity.new(attributes)
          identity.save.should_not be_true
        end
      end
    end
  end

end