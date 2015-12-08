# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::Identity do

  describe "constants" do
    it { expect(described_class::ATTRIBUTES).to eq([:accounts, :birth_date, :country, :cpf, :email, :first_name, :gender, :id_token, :is_active, :language, :last_name, :nickname, :notifications, :send_myfreecomm_news, :send_partner_news, :services, :timezone, :update_info_url, :uuid, :password, :password2, :must_change_password, :inhibit_activation_message, :tos, :bio, :position, :city, :company, :profession, :identity_info_url, :state, :email_list]) }
    it { expect(described_class::UPDATABLE_ATTRIBUTES).to eq([:first_name, :last_name, :nickname, :cpf, :birth_date, :gender, :send_myfreecomm_news, :send_partner_news, :country, :language, :timezone, :bio, :position, :city, :company, :profession, :state]) }
    it { expect(described_class::CREATABLE_ATTRIBUTES).to eq([:first_name, :last_name, :nickname, :cpf, :birth_date, :gender, :send_myfreecomm_news, :send_partner_news, :country, :language, :timezone, :bio, :position, :city, :company, :profession, :state, :email, :password, :password2, :must_change_password, :tos, :inhibit_activation_message]) }
  end

  describe ".new" do
    it "should instanciate an empty object" do
      identity = described_class.new
      expect(identity.attributes).to eq({:accounts=>nil, :birth_date=>nil, :country=>nil, :cpf=>nil, :email=>nil, :first_name=>nil, :gender=>nil, :id_token=>nil, :is_active=>nil, :language=>nil, :last_name=>nil, :nickname=>nil, :notifications=>nil, :send_myfreecomm_news=>nil, :send_partner_news=>nil, :services=>nil, :timezone=>nil, :update_info_url=>nil, :uuid=>nil, :password=>nil, :password2=>nil, :must_change_password=>nil, :inhibit_activation_message=>nil, :tos=>nil, :bio=>nil, :position=>nil, :city=>nil, :company=>nil, :profession=>nil, :identity_info_url=>nil, :state=>nil, :email_list=>nil})
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
      identity = described_class.new(attributes)
      expect(identity.attributes).to eq({:accounts=>[], :birth_date=>"1945-10-27", :country=>"Brasil", :cpf=>nil, :email=>"lula@example.com", :first_name=>"Luis Inácio", :gender=>"M", :id_token=>nil, :is_active=>true, :language=>"pt_BR", :last_name=>"da Silva", :nickname=>"Lula", :notifications=>{"count"=>0, "list"=>"/notifications/api/"}, :send_myfreecomm_news=>false, :send_partner_news=>false, :services=>{"myfinance"=>"/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/myfinance/", "account_manager"=>"/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/account_manager/"}, :timezone=>"GMT-3", :update_info_url=>"/profile/api/info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/", :uuid=>"a5868d14-6529-477a-9c6b-a09dd42a7cd2", :password=>nil, :password2=>nil, :must_change_password=>nil, :inhibit_activation_message=>nil, :tos=>nil, :bio=>nil, :position=>nil, :city=>nil, :company=>nil, :profession=>nil, :identity_info_url=>nil, :state=>nil, :email_list=>nil})
      expect(identity.last_name).to eq("da Silva")
      expect(identity.is_active).to eq(true)
      expect(identity.timezone).to eq("GMT-3")
      expect(identity.nickname).to eq("Lula")
      expect(identity.first_name).to eq("Luis Inácio")
      expect(identity.send_partner_news).to eq(false)
      expect(identity.uuid).to eq("a5868d14-6529-477a-9c6b-a09dd42a7cd2")
      expect(identity.language).to eq("pt_BR")
      expect(identity.country).to eq("Brasil")
      expect(identity.update_info_url).to eq("/profile/api/info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/")
      expect(identity.send_myfreecomm_news).to eq(false)
      expect(identity.gender).to eq("M")
      expect(identity.birth_date).to eq("1945-10-27")
      expect(identity.email).to eq("lula@example.com")
      expect(identity.notifications).to eq({"count" => 0, "list" => "/notifications/api/"})
      expect(identity.accounts).to eq([])
      expect(identity.services).to eq({"myfinance" => "/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/myfinance/", "account_manager" => "/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/account_manager/"})
      expect(identity.password).to be_nil
      expect(identity.password2).to be_nil
      expect(identity.must_change_password).to be_nil
      expect(identity.inhibit_activation_message).to be_nil
      expect(identity.tos).to be_nil
    end
  end

  describe "#== and #===" do
    it "should identify two profiles with the same uuid as equal" do
      p1 = described_class.new('uuid' => 'some-uuid')
      p2 = described_class.new('uuid' => 'some-uuid')
      expect(p1).to eq(p2)
      expect(p1).not_to be === p2
      expect(p2).to eq(p1)
      expect(p2).not_to be === p1
    end
    it "should identify two profiles with different uuids as different" do
      p1 = described_class.new('uuid' => 'some-uuid-1')
      p2 = described_class.new('uuid' => 'some-uuid-2')
      expect(p1).not_to eq(p2)
      expect(p1).not_to be === p2
      expect(p2).not_to eq(p1)
      expect(p2).not_to be === p1
      p3 = described_class.new
      expect(p1).not_to eq(p3)
      expect(p3).not_to eq(p1)
      expect(p3).not_to be === p1
    end
  end

  describe ".find", :vcr => true do
    it "should find the requested profile by uuid" do
      identity = described_class.find("5e32f927-c4ab-404e-a91c-b2abc05afb56")
      expect(identity).to be_instance_of(described_class)
      expect(identity.uuid).to eq('5e32f927-c4ab-404e-a91c-b2abc05afb56')
      expect(identity).to be_persisted
      expect(identity.email).to eq('teste@teste.com')
      expect(identity.update_info_url).to eq('/accounts/api/identities/5e32f927-c4ab-404e-a91c-b2abc05afb56/')
      expect(identity.accounts.size).to eq(9)
      expect(identity.accounts.map { |a| a['expiration'] }.uniq).to eq([nil, "2014-05-01 00:00:00"])
      expect(identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] rescue nil }.sort).to eq([nil])
    end
    it "should find the requested profile by uuid, including expired accounts" do
      identity = described_class.find("5e32f927-c4ab-404e-a91c-b2abc05afb56", true)
      expect(identity.accounts.size).to eq(10)
      expect(identity.accounts.map { |a| a['expiration'] }.uniq).to eq([nil, "2013-04-02 00:00:00", "2014-05-01 00:00:00"])
      expect(identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] rescue nil }.sort).to eq([nil])
    end
    it "should find the requested profile by uuid, including other services" do
      identity = described_class.find("5e32f927-c4ab-404e-a91c-b2abc05afb56", false, true)
      expect(identity.accounts.size).to eq(10)
      expect(identity.accounts.map { |a| a['expiration'] }.uniq).to eq([nil, "2014-05-01 00:00:00"])
      expect(identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] }.sort).to eq(["identity_client", "vc-promove"])
    end
    it "should find the requested profile by uuid, including other services and expired accounts" do
      identity = described_class.find("5e32f927-c4ab-404e-a91c-b2abc05afb56", true, true)
      expect(identity.accounts.size).to eq(11)
      expect(identity.accounts.map { |a| a['expiration'] }.uniq).to eq([nil, "2013-04-02 00:00:00", "2014-05-01 00:00:00"])
      expect(identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] }.sort).to eq(["identity_client", "vc-promove"])
    end
    # REGRSSION
    it "should return the is_active and id_token fields" do
      identity = described_class.find('13b972ab-0946-4a5b-8217-60255a9cbee7', true, true)
      expect(identity.is_active).to be_truthy
      expect(identity.id_token).to be_nil # não mostra token pois não foi autenticado com a senha do usuário
    end
    it "should raise an error if no profiles exist with that uuid" do
      expect {
        described_class.find("invalid-uuid")
      }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
    end
  end

  describe ".find_by_email", :vcr => true do
    it "should find the requested profile by email" do
      identity = described_class.find_by_email("teste@teste.com")
      expect(identity).to be_instance_of(described_class)
      expect(identity.uuid).to eq('5e32f927-c4ab-404e-a91c-b2abc05afb56')
      expect(identity).to be_persisted
      expect(identity.email).to eq('teste@teste.com')
      expect(identity.update_info_url).to eq('/accounts/api/identities/5e32f927-c4ab-404e-a91c-b2abc05afb56/')
      expect(identity.accounts.size).to eq(9)
      expect(identity.accounts.map { |a| a['expiration'] }.uniq).to eq([nil, "2014-05-01 00:00:00"])
      expect(identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] rescue nil }.sort).to eq([nil])
      expect(identity.services.size).to eq(1)
      expect(identity.services.keys).to eq(['identity_client'])
    end
    it "should find the requested profile by email, including expired accounts" do
      identity = described_class.find_by_email("teste@teste.com", true)
      expect(identity.accounts.size).to eq(10)
      expect(identity.accounts.map { |a| a['expiration'] }.uniq).to eq([nil, "2013-04-02 00:00:00", "2014-05-01 00:00:00"])
      expect(identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] rescue nil }.sort).to eq([nil])
      expect(identity.services.size).to eq(1)
      expect(identity.services.keys).to eq(['identity_client'])
    end
    it "should find the requested profile by email, including other services" do
      identity = described_class.find_by_email("teste@teste.com", false, true)
      expect(identity.accounts.size).to eq(10)
      expect(identity.accounts.map { |a| a['expiration'] }.uniq).to eq([nil, "2014-05-01 00:00:00"])
      expect(identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] }.sort).to eq(["identity_client", "vc-promove"])
    end
    it "should find the requested profile by email, including other services and expired accounts" do
      identity = described_class.find_by_email("teste@teste.com", true, true)
      expect(identity.accounts.size).to eq(11)
      expect(identity.accounts.map { |a| a['expiration'] }.uniq).to eq([nil, "2013-04-02 00:00:00", "2014-05-01 00:00:00"])
      expect(identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] }.sort).to eq(["identity_client", "vc-promove"])
    end
    # REGRSSION
    it "should return the is_active and id_token fields" do
      identity = described_class.find_by_email('mobileteste269@mailinator.com', true, true)
      expect(identity.is_active).to be_truthy
      expect(identity.id_token).to be_nil # não mostra token pois não foi autenticado com a senha do usuário
    end
    it "should raise an error if no profiles exist with that email" do
      expect {
        described_class.find("invalid@email.com")
      }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
    end
  end

  describe ".profile", :vcr => true do
    it "should find the requested profile by email" do
      identity = described_class.profile('8923199e-6c43-415a-bbd1-2e302fdf8d96')
      expect(identity).to be_instance_of(described_class)
      expect(identity.bio).to eq('I\'m the Kingslayer!')
      expect(identity.position).to eq('Knight')
      expect(identity.language).to eq('ur')
      expect(identity.city).to eq('Casterly Rock')
      expect(identity.gender).to eq('M')
      expect(identity.company).to eq('Lannister House')
      expect(identity.profession).to eq('Kingslayer')
      expect(identity.identity_info_url).to eq('http://sandbox.app.passaporteweb.com.br/accounts/api/identities/8923199e-6c43-415a-bbd1-2e302fdf8d96/')
      expect(identity.state).to eq('AC')
      expect(identity.country).to eq('Westeros')
      expect(identity.birth_date).to eq('1950-01-01')
      expect(identity.timezone).to eq('Pacific/Midway')
      expect(identity.nickname).to eq('Jaime')
      expect(identity.email_list.count).to eq(2)
      # Primary e-mail
      expect(identity.email_list[0]['address']).to eq('jaime.lannister@mailinator.com')
      expect(identity.email_list[0]['is_primary']).to be_truthy
      expect(identity.email_list[0]['is_active']).to be_truthy
      # Secondary email
      expect(identity.email_list[1]['address']).to eq('kingslayer@mailinator.com')
      expect(identity.email_list[1]['is_primary']).to be_falsy
      expect(identity.email_list[1]['is_active']).to be_truthy
    end
    it "should raise an error if no profiles exist with that email" do
      expect {
        described_class.profile("invalid-uuid")
      }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
    end
  end

  describe ".authenticate", vcr: true do
    it "should return an instance of Identity if the password is correct for the given email" do
      identity = described_class.authenticate('teste@teste.com', '123456')
      expect(identity).to be_instance_of(described_class)
      expect(identity).to be_persisted
      expect(identity.uuid).to eq('5e32f927-c4ab-404e-a91c-b2abc05afb56')
      expect(identity.email).to eq('teste@teste.com')
      expect(identity.update_info_url).to eq('/accounts/api/identities/5e32f927-c4ab-404e-a91c-b2abc05afb56/')
    end
    # REGRSSION
    it "should return the is_active and id_token fields" do
      identity = described_class.authenticate('mobileteste269@mailinator.com', 'vivalasvegas')
      expect(identity.is_active).to be_truthy
      expect(identity.id_token).to eq('9864ec27fb4fd866f6fad5bc041d0363d0bc0fd2945858a1')
    end
    it "should return false if the password is wrong for the given email" do
      expect(described_class.authenticate('teste@teste.com', 'wrong password')).to be_falsy
    end
    it "should return false if no Identity exists on PassaporteWeb with that email" do
      described_class.authenticate('non_existing_email@teste.com', 'some password')
    end
  end

  describe "#authenticate", vcr: true do
    let(:identity) { described_class.find("5e32f927-c4ab-404e-a91c-b2abc05afb56") }
    it "should return true if the password is correct" do
      expect(identity.authenticate('123456')).to be_truthy
    end
    it "should return false if the password is wrong" do
      expect(identity.authenticate('wrong password')).to be_falsy
    end
    it "should raise an error if the email is not set" do
      identity.instance_variable_set(:@email, nil)
      expect {
        identity.authenticate('some password')
      }.to raise_error(ArgumentError, 'email must be set')
    end
  end

  describe "#save", :vcr => true do
    describe "PUT" do
      let(:identity) { described_class.find("5e32f927-c4ab-404e-a91c-b2abc05afb56") }
      context "on success" do
        it "should update the profile attributes on the server" do
          expect(identity.first_name).to eq('Testador')
          expect(identity).to be_persisted
          identity.first_name = 'Testador 2'
          expect(identity.save).to be_truthy
          expect(identity).to be_persisted
          expect(identity.first_name).to eq('Testador 2')

          identity = described_class.find("5e32f927-c4ab-404e-a91c-b2abc05afb56")
          expect(identity.first_name).to eq('Testador 2')
        end
      end
      context "on failure" do
        it "should return false and set the errors hash" do
          identity.cpf = 42
          expect(identity).to be_persisted
          expect(identity.save).to be_falsy
          expect(identity).to be_persisted
          expect(identity.errors).to eq({"cpf" => ["Certifique-se de que o valor tenha no mínimo 11 caracteres (ele possui 2)."]})
        end
      end
    end
    describe "POST" do
      context "on success" do
        it "should save with password, password2 and must_change_password" do
          attributes = {
            "email" => "lula_luis2002@example.com",
            "first_name" => "Luis Inácio",
            "last_name" => "da Silva",
            "password" => "rW5oHxYB",
            "password2" => "rW5oHxYB",
            "must_change_password" => true,
            "tos" => true
          }
          identity = described_class.new(attributes)
          expect(identity).not_to be_persisted
          expect(identity.save).to be_truthy
          expect(identity).to be_persisted
        end
        it "should save with all params" do
          attributes = {
            "email" => "lula_luis2006@example.com",
            "first_name" => "Luis Inácio",
            "last_name" => "da Silva",
            "password" => "rW5oHxYB",
            "password2" => "rW5oHxYB",
            "must_change_password" => true,
            "tos" => true,
            "inhibit_activation_message" => false,
            "cpf" => "613.862.250-29",
            "send_partner_news" => false,
            "send_myfreecomm_news" => false
          }
          identity = described_class.new(attributes)
          expect(identity).not_to be_persisted
          expect(identity.save).to be_truthy
          expect(identity).to be_persisted
        end
        # REGRESSION
        it "should send the inhibit_activation_message information" do
          attributes = {
            email: 'obiwan88@suremail.info',
            password: 'theforce',
            password2: 'theforce',
            tos: true,
            inhibit_activation_message: true,
            send_partner_news: false,
            send_myfreecomm_news: true
          }
          identity = described_class.new(attributes)
          mock_response = double('response', code: 201, body: MultiJson.encode(attributes))
          expect(PassaporteWeb::Http).to receive(:post).with("/accounts/api/create/", attributes).and_return(mock_response)
          expect(identity.save).to be_truthy
        end
      end
      context "on failure" do
        it "should not save" do
          attributes = {
            "email" => "lula_luis81@example.com",
            "first_name" => "Luis Inácio",
            "last_name" => "da Silva",
            "tos" => true
          }
          identity = described_class.new(attributes)
          expect(identity).to_not be_persisted
          expect(identity.save).to_not be_truthy
          expect(identity).to_not be_persisted
          expect(identity.errors).to eq({"password2"=>["Este campo é obrigatório."], "password"=>["Este campo é obrigatório."]})
        end
      end
    end
  end

end
