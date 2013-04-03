# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::Notification do

  describe "constants" do
    it { PassaporteWeb::Notification::ATTRIBUTES.should == [:destination, :body, :target_url, :scheduled_to] }
  end

  describe ".new" do
    it "should instanciate an empty object" do
      notification = PassaporteWeb::Notification.new
      notification.attributes.should == {:destination=>nil, :body=>nil, :target_url=>nil, :scheduled_to=>nil}
    end
    it "should instanciate an object with attributes set" do
      attributes = {
        "destination" => "ac3540c7-5453-424d-bdfd-8ef2d9ff78df",
        "body" => "Feliz ano novo!",
        "target_url" => "https://app.passaporteweb.com.br",
        "scheduled_to" => "2012-01-01 00:00:00"
      }
      notification = PassaporteWeb::Notification.new(attributes)
      notification.attributes.should == {:destination=>"ac3540c7-5453-424d-bdfd-8ef2d9ff78df", :body=>"Feliz ano novo!", :target_url=>"https://app.passaporteweb.com.br", :scheduled_to=>"2012-01-01 00:00:00"}
      notification.destination.should == "ac3540c7-5453-424d-bdfd-8ef2d9ff78df"
      notification.body.should == "Feliz ano novo!"
      notification.target_url.should == "https://app.passaporteweb.com.br"
      notification.scheduled_to.should == "2012-01-01 00:00:00"
    end
  end

  describe ".list", :vcr => true do
    before(:each) do
      PassaporteWeb.configuration.user_token = "f01d30c0a2e878fecc838735560253f9e9395932f5337f40"
    end

    context "on success" do
      it "should return listed with Notification of User without params" do
        notification = PassaporteWeb::Notification.list
        notification.should be_instance_of(Array)
        notification.size.should >= 1
        notification.first["body"].should == "\"oioioi\""
        notification.first["absolute_url"].should == "/notifications/api/2ca046be-0178-418d-80ac-3a334c264009/"
      end

      it "should return listed with Notification of User with params" do
        notification = PassaporteWeb::Notification.list(false, '', 1, 2, "oldest-first")
        notification.should be_instance_of(Array)
        notification.size.should >= 1
        notification.first["body"].should == "\"oioioi\""
        notification.first["absolute_url"].should == "/notifications/api/2ca046be-0178-418d-80ac-3a334c264009/"
      end
    end

    context "on failed" do
      it "400 Bad Request" do
        PassaporteWeb::Notification.list(false, '', 1, 2, 2).first.should == {"ordering"=>["Faça uma escolha válida. 2 não está disponível."]}
      end

      it "404 Not Found" do
        expect {
          PassaporteWeb::Notification.list(false, '', 20, 2, "oldest-first")
        }.to raise_error(RestClient::ResourceNotFound, '404 Resource Not Found')
      end
    end
  end

  describe ".count", :vcr => true do
    before(:each) do
      PassaporteWeb.configuration.user_token = "f01d30c0a2e878fecc838735560253f9e9395932f5337f40"
    end

    context "on success" do
      it "should return count of notifications" do
        notification = PassaporteWeb::Notification.count
        notification.should be_instance_of(Hash)
        notification["count"].should >= 1
        notification["destination"].should == "385f5f3c-8d33-4b95-9e0d-e87962985244"
      end
    end

    context "on failed" do
      it "400 BAD REQUEST" do
        PassaporteWeb::Notification.count(nil, "o").first.should == {"since"=>["Informe uma data/hora válida."]}
      end

      it "401 Unauthorized" do
        PassaporteWeb.configuration.user_token = "f01d30c0a2e878fecc838735560253f9e9395932f5337f43"
        PassaporteWeb::Notification.count.first.should == {"detail"=>"You need to login or otherwise authenticate the request."}
      end
    end
  end

end
