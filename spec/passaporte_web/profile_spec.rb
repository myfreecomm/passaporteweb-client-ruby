# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::Profile do

  describe ".new" do
    it "should instanciate an empty object" do
      profile = PassaporteWeb::Profile.new
      profile.attributes.should == {:accounts=>nil, :birth_date=>nil, :country=>nil, :cpf=>nil, :email=>nil, :first_name=>nil, :gender=>nil, :is_active=>nil, :language=>nil, :last_name=>nil, :nickname=>nil, :notifications=>nil, :send_myfreecomm_news=>nil, :send_partner_news=>nil, :services=>nil, :timezone=>nil, :update_info_url=>nil, :uuid=>nil}
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
        }
      }
      profile = PassaporteWeb::Profile.new(attributes)
      profile.attributes.should == {:accounts=>[], :birth_date=>"1945-10-27", :country=>"Brasil", :cpf=>nil, :email=>"lula@example.com", :first_name=>"Luis Inácio", :gender=>"M", :is_active=>true, :language=>"pt_BR", :last_name=>"da Silva", :nickname=>"Lula", :notifications=>{"count"=>0, "list"=>"/notifications/api/"}, :send_myfreecomm_news=>false, :send_partner_news=>false, :services=>{"myfinance"=>"/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/myfinance/", "account_manager"=>"/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/account_manager/"}, :timezone=>"GMT-3", :update_info_url=>"/profile/api/info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/", :uuid=>"a5868d14-6529-477a-9c6b-a09dd42a7cd2"}
      profile.last_name.should == "da Silva"
      profile.is_active.should == true
      profile.timezone.should == "GMT-3"
      profile.nickname.should == "Lula"
      profile.first_name.should == "Luis Inácio"
      profile.send_partner_news.should == false
      profile.uuid.should == "a5868d14-6529-477a-9c6b-a09dd42a7cd2"
      profile.language.should == "pt_BR"
      profile.country.should == "Brasil"
      profile.update_info_url.should == "/profile/api/info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/"
      profile.send_myfreecomm_news.should == false
      profile.gender.should == "M"
      profile.birth_date.should == "1945-10-27"
      profile.email.should == "lula@example.com"
      profile.notifications.should == {"count" => 0, "list" => "/notifications/api/"}
      profile.accounts.should == []
      profile.services.should == {"myfinance" => "/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/myfinance/", "account_manager" => "/accounts/api/service-info/a5868d14-6529-477a-9c6b-a09dd42a7cd2/account_manager/"}
    end
  end

  describe "#== and #===" do
    it "should identify two profiles with the same uuid as equal" do
      p1 = PassaporteWeb::Profile.new('uuid' => 'some-uuid')
      p2 = PassaporteWeb::Profile.new('uuid' => 'some-uuid')
      p1.should == p2
      p1.should_not === p2
      p2.should == p1
      p2.should_not === p1
    end
    it "should identify two profiles with different uuids as different" do
      p1 = PassaporteWeb::Profile.new('uuid' => 'some-uuid-1')
      p2 = PassaporteWeb::Profile.new('uuid' => 'some-uuid-2')
      p1.should_not == p2
      p1.should_not === p2
      p2.should_not == p1
      p2.should_not === p1
      p3 = PassaporteWeb::Profile.new
      p1.should_not == p3
      p3.should_not == p1
      p3.should_not === p1
    end
  end

  describe ".find", :vcr => true do
    it "should find the requested profile by uuid" do
      # TODO
    end
  end

end
