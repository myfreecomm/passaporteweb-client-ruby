# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::Identity do

  describe "constants" do
    it { described_class::ATTRIBUTES.should == [:accounts, :birth_date, :country, :cpf, :email, :first_name, :gender, :id_token, :is_active, :language, :last_name, :nickname, :notifications, :send_myfreecomm_news, :send_partner_news, :services, :timezone, :update_info_url, :uuid, :password, :password2, :must_change_password, :inhibit_activation_message, :tos, :bio, :position, :city, :company, :profession, :identity_info_url, :state, :email_list] }
    it { described_class::UPDATABLE_ATTRIBUTES.should == [:first_name, :last_name, :nickname, :cpf, :birth_date, :gender, :send_myfreecomm_news, :send_partner_news, :country, :language, :timezone, :bio, :position, :city, :company, :profession, :state] }
    it { described_class::CREATABLE_ATTRIBUTES.should == [:first_name, :last_name, :nickname, :cpf, :birth_date, :gender, :send_myfreecomm_news, :send_partner_news, :country, :language, :timezone, :bio, :position, :city, :company, :profession, :state, :email, :password, :password2, :must_change_password, :tos, :inhibit_activation_message] }
  end

  describe ".new" do
    it "should instanciate an empty object" do
      identity = described_class.new
      identity.attributes.should == {:accounts=>nil, :birth_date=>nil, :country=>nil, :cpf=>nil, :email=>nil, :first_name=>nil, :gender=>nil, :id_token=>nil, :is_active=>nil, :language=>nil, :last_name=>nil, :nickname=>nil, :notifications=>nil, :send_myfreecomm_news=>nil, :send_partner_news=>nil, :services=>nil, :timezone=>nil, :update_info_url=>nil, :uuid=>nil, :password=>nil, :password2=>nil, :must_change_password=>nil, :inhibit_activation_message=>nil, :tos=>nil, :bio=>nil, :position=>nil, :city=>nil, :company=>nil, :profession=>nil, :identity_info_url=>nil, :state=>nil, :email_list=>nil}
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
      identity.attributes.should == {:accounts=>[], :birth_date=>"1945-10-27", :country=>"Brasil", :cpf=>nil, :email=>"lula@example.com", :first_name=>"Luis Inácio", :gender=>"M", :id_token=>nil, :is_active=>true, :language=>"pt_BR", :last_name=>"da Silva", :nickname=>"Lula", :notifications=>{"count"=>0, "list"=>"/notifications/api/"}, :send_myfreecomm_news=>false, :send_partner_news=>false, :services=>{"myfinance"=>"/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/myfinance/", "account_manager"=>"/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/account_manager/"}, :timezone=>"GMT-3", :update_info_url=>"/profile/api/info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/", :uuid=>"a5868d14-6529-477a-9c6b-a09dd42a7cd2", :password=>nil, :password2=>nil, :must_change_password=>nil, :inhibit_activation_message=>nil, :tos=>nil, :bio=>nil, :position=>nil, :city=>nil, :company=>nil, :profession=>nil, :identity_info_url=>nil, :state=>nil, :email_list=>nil}
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
      p1 = described_class.new('uuid' => 'some-uuid')
      p2 = described_class.new('uuid' => 'some-uuid')
      p1.should == p2
      p1.should_not === p2
      p2.should == p1
      p2.should_not === p1
    end
    it "should identify two profiles with different uuids as different" do
      p1 = described_class.new('uuid' => 'some-uuid-1')
      p2 = described_class.new('uuid' => 'some-uuid-2')
      p1.should_not == p2
      p1.should_not === p2
      p2.should_not == p1
      p2.should_not === p1
      p3 = described_class.new
      p1.should_not == p3
      p3.should_not == p1
      p3.should_not === p1
    end
  end

  describe ".find", :vcr => true do
    it "should find the requested profile by uuid" do
      identity = described_class.find("5e32f927-c4ab-404e-a91c-b2abc05afb56")
      identity.should be_instance_of(described_class)
      identity.uuid.should == '5e32f927-c4ab-404e-a91c-b2abc05afb56'
      identity.should be_persisted
      identity.email.should == 'teste@teste.com'
      identity.update_info_url.should == '/accounts/api/identities/5e32f927-c4ab-404e-a91c-b2abc05afb56/'
      identity.accounts.size.should == 9
      identity.accounts.map { |a| a['expiration'] }.uniq.should == [nil, "2014-05-01 00:00:00"]
      identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] rescue nil }.sort.should == [nil]
    end
    it "should find the requested profile by uuid, including expired accounts" do
      identity = described_class.find("5e32f927-c4ab-404e-a91c-b2abc05afb56", true)
      identity.accounts.size.should == 10
      identity.accounts.map { |a| a['expiration'] }.uniq.should == [nil, "2013-04-02 00:00:00", "2014-05-01 00:00:00"]
      identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] rescue nil }.sort.should == [nil]
    end
    it "should find the requested profile by uuid, including other services" do
      identity = described_class.find("5e32f927-c4ab-404e-a91c-b2abc05afb56", false, true)
      identity.accounts.size.should == 10
      identity.accounts.map { |a| a['expiration'] }.uniq.should == [nil, "2014-05-01 00:00:00"]
      identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] }.sort.should == ["identity_client", "vc-promove"]
    end
    it "should find the requested profile by uuid, including other services and expired accounts" do
      identity = described_class.find("5e32f927-c4ab-404e-a91c-b2abc05afb56", true, true)
      identity.accounts.size.should == 11
      identity.accounts.map { |a| a['expiration'] }.uniq.should == [nil, "2013-04-02 00:00:00", "2014-05-01 00:00:00"]
      identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] }.sort.should == ["identity_client", "vc-promove"]
    end
    # REGRSSION
    it "should return the is_active and id_token fields" do
      identity = described_class.find('13b972ab-0946-4a5b-8217-60255a9cbee7', true, true)
      expect(identity.is_active).to be_truthy
      identity.id_token.should be_nil # não mostra token pois não foi autenticado com a senha do usuário
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
      identity.should be_instance_of(described_class)
      identity.uuid.should == '5e32f927-c4ab-404e-a91c-b2abc05afb56'
      identity.should be_persisted
      identity.email.should == 'teste@teste.com'
      identity.update_info_url.should == '/accounts/api/identities/5e32f927-c4ab-404e-a91c-b2abc05afb56/'
      identity.accounts.size.should == 9
      identity.accounts.map { |a| a['expiration'] }.uniq.should == [nil, "2014-05-01 00:00:00"]
      identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] rescue nil }.sort.should == [nil]
      identity.services.size.should == 1
      identity.services.keys.should == ['identity_client']
    end
    it "should find the requested profile by email, including expired accounts" do
      identity = described_class.find_by_email("teste@teste.com", true)
      identity.accounts.size.should == 10
      identity.accounts.map { |a| a['expiration'] }.uniq.should == [nil, "2013-04-02 00:00:00", "2014-05-01 00:00:00"]
      identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] rescue nil }.sort.should == [nil]
      identity.services.size.should == 1
      identity.services.keys.should == ['identity_client']
    end
    it "should find the requested profile by email, including other services" do
      identity = described_class.find_by_email("teste@teste.com", false, true)
      identity.accounts.size.should == 10
      identity.accounts.map { |a| a['expiration'] }.uniq.should == [nil, "2014-05-01 00:00:00"]
      identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] }.sort.should == ["identity_client", "vc-promove"]
    end
    it "should find the requested profile by email, including other services and expired accounts" do
      identity = described_class.find_by_email("teste@teste.com", true, true)
      identity.accounts.size.should == 11
      identity.accounts.map { |a| a['expiration'] }.uniq.should == [nil, "2013-04-02 00:00:00", "2014-05-01 00:00:00"]
      identity.accounts.map { |a| a['services'] }.flatten.uniq.map { |s| s['slug'] }.sort.should == ["identity_client", "vc-promove"]
    end
    # REGRSSION
    it "should return the is_active and id_token fields" do
      identity = described_class.find_by_email('mobileteste269@mailinator.com', true, true)
      expect(identity.is_active).to be_truthy
      identity.id_token.should be_nil # não mostra token pois não foi autenticado com a senha do usuário
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
      identity.should be_instance_of(described_class)
      identity.bio.should == 'I\'m the Kingslayer!'
      identity.position.should == 'Knight'
      identity.language.should == 'ur'
      identity.city.should == 'Casterly Rock'
      identity.gender.should == 'M'
      identity.company.should == 'Lannister House'
      identity.profession.should == 'Kingslayer'
      identity.identity_info_url.should == 'http://sandbox.app.passaporteweb.com.br/accounts/api/identities/8923199e-6c43-415a-bbd1-2e302fdf8d96/'
      identity.state.should == 'AC'
      identity.country.should == 'Westeros'
      identity.birth_date.should == '1950-01-01'
      identity.timezone.should == 'Pacific/Midway'
      identity.nickname.should == 'Jaime'
      identity.email_list.count.should == 2
      # Primary e-mail
      identity.email_list[0]['address'].should == 'jaime.lannister@mailinator.com'
      expect(identity.email_list[0]['is_primary']).to be_truthy
      expect(identity.email_list[0]['is_active']).to be_truthy
      # Secondary email
      identity.email_list[1]['address'].should == 'kingslayer@mailinator.com'
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
      identity.should be_instance_of(described_class)
      identity.should be_persisted
      identity.uuid.should == '5e32f927-c4ab-404e-a91c-b2abc05afb56'
      identity.email.should == 'teste@teste.com'
      identity.update_info_url.should == '/accounts/api/identities/5e32f927-c4ab-404e-a91c-b2abc05afb56/'
    end
    # REGRSSION
    it "should return the is_active and id_token fields" do
      identity = described_class.authenticate('mobileteste269@mailinator.com', 'vivalasvegas')
      expect(identity.is_active).to be_truthy
      identity.id_token.should == '9864ec27fb4fd866f6fad5bc041d0363d0bc0fd2945858a1'
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
          identity.first_name.should == 'Testador'
          identity.should be_persisted
          identity.first_name = 'Testador 2'
          expect(identity.save).to be_truthy
          identity.should be_persisted
          identity.first_name.should == 'Testador 2'

          identity = described_class.find("5e32f927-c4ab-404e-a91c-b2abc05afb56")
          identity.first_name.should == 'Testador 2'
        end
      end
      context "on failure" do
        it "should return false and set the errors hash" do
          identity.cpf = 42
          identity.should be_persisted
          expect(identity.save).to be_falsy
          identity.should be_persisted
          identity.errors.should == {"cpf" => ["Certifique-se de que o valor tenha no mínimo 11 caracteres (ele possui 2)."]}
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
          identity.should_not be_persisted
          expect(identity.save).to be_truthy
          identity.should be_persisted
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
          identity.should_not be_persisted
          expect(identity.save).to be_truthy
          identity.should be_persisted
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
          PassaporteWeb::Http.should_receive(:post).with("/accounts/api/create/", attributes).and_return(mock_response)
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
          identity.should_not be_persisted
          expect(identity.save).to_not be_truthy
          identity.should_not be_persisted
          identity.errors.should == {"password2"=>["Este campo é obrigatório."], "password"=>["Este campo é obrigatório."]}
        end
      end
    end
  end

end
