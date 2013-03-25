# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::RegistrationIdentity do

  describe ".new" do
    it "should instanciate an empty object" do
      registration_identity = PassaporteWeb::RegistrationIdentity.new
      registration_identity.attributes.should == {:email=>nil, :first_name=>nil, :last_name=>nil,
                                                  :password=>nil, :password2=>nil, :must_change_password=>nil,
                                                  :inhibit_activation_message=>nil, :cpf=>nil, :send_myfreecomm_news=>nil,
                                                  :send_partner_news=>nil, :tos=>nil}
    end

    it "should instanciate an object with attributes set" do
      attributes = {
        "email" => "equipemyfinance@myfreecomm.com.br",
        "first_name" => "Luis Inácio",
        "last_name" => "'nao sei de nada' da Silva",
        "send_partner_news" => false,
        "send_myfreecomm_news" => false,
        "password" => "lulala",
        "password2" => "lulala",
        "must_change_password" => false,
        "inhibit_activation_message" => false,
        "cpf" => "157.027.254-92",
        "tos" => true
      }
      registration_identity = PassaporteWeb::RegistrationIdentity.new(attributes)
      registration_identity.attributes.should == {:email=>"equipemyfinance@myfreecomm.com.br", :first_name=>"Luis Inácio", :last_name=>"'nao sei de nada' da Silva", :password=>"lulala", :password2=>"lulala", :must_change_password=>false, :inhibit_activation_message=>false, :cpf=>"157.027.254-92", :send_myfreecomm_news=>false, :send_partner_news=>false, :tos=>true}
      registration_identity.last_name.should == "'nao sei de nada' da Silva"
      registration_identity.first_name.should == "Luis Inácio"
      registration_identity.send_partner_news.should == false
      registration_identity.send_myfreecomm_news.should == false
      registration_identity.email.should == "equipemyfinance@myfreecomm.com.br"
      registration_identity.password.should == "lulala"
      registration_identity.password2.should == "lulala"
      registration_identity.must_change_password.should == false
      registration_identity.inhibit_activation_message.should == false
      registration_identity.cpf.should == "157.027.254-92"
      registration_identity.tos.should == true
    end
  end

  describe ".save", :vcr => true do
    it "should save with password, password2 and must_change_password" do
      attributes = {
        "email" => "lula_luis4@example.com",
        "first_name" => "Luis Inácio",
        "last_name" => "da Silva",
        "password" => "rW5oHxYB",
        "password2" => "rW5oHxYB",
        "must_change_password" => true,
        "tos" => true
      }
      registration_identity = PassaporteWeb::RegistrationIdentity.new(attributes)
      registration_identity.save.should be_true
    end

    it "should sabe with all params" do
      attributes = {
        "email" => "lula_luis7@example.com",
        "first_name" => "Luis Inácio",
        "last_name" => "da Silva",
        "password" => "rW5oHxYB",
        "password2" => "rW5oHxYB",
        "must_change_password" => true,
        "tos" => true,
        "inhibit_activation_message" => false,
        "cpf" => "353.423.680-73",
        "send_partner_news" => false,
        "send_myfreecomm_news" => false
      }
      registration_identity = PassaporteWeb::RegistrationIdentity.new(attributes)
      registration_identity.save.should be_true
    end
  end
end