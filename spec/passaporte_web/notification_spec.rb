# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::Notification do

  describe "constants" do
    it { expect(PassaporteWeb::Notification::ATTRIBUTES).to eq([:body, :target_url, :uuid, :absolute_url, :scheduled_to, :sender_data, :read_at, :notification_type, :destination]) }
    it { expect(PassaporteWeb::Notification::CREATABLE_ATTRIBUTES).to eq([:body, :target_url, :scheduled_to, :destination]) }
  end

  describe ".new" do
    it "should instanciate an empty object" do
      notification = PassaporteWeb::Notification.new
      expect(notification).not_to be_persisted
      expect(notification.attributes).to eq({:body=>nil, :target_url=>nil, :uuid=>nil, :absolute_url=>nil, :scheduled_to=>nil, :sender_data=>nil, :read_at=>nil, :notification_type=>nil, :destination=>nil})
      expect(notification.uuid).to be_nil
      expect(notification.destination).to be_nil
      expect(notification.body).to be_nil
      expect(notification.target_url).to be_nil
      expect(notification.scheduled_to).to be_nil
      expect(notification.absolute_url).to be_nil
      expect(notification.sender_data).to be_nil
      expect(notification.read_at).to be_nil
      expect(notification.notification_type).to be_nil
    end
    it "should instanciate an object with attributes set" do
      attributes = {
        "destination" => "ac3540c7-5453-424d-bdfd-8ef2d9ff78df",
        "body" => "Feliz ano novo!",
        "target_url" => "https://app.passaporteweb.com.br",
        "scheduled_to" => "2012-01-01 00:00:00"
      }
      notification = PassaporteWeb::Notification.new(attributes)
      expect(notification).not_to be_persisted
      expect(notification.uuid).to be_nil
      expect(notification.attributes).to eq({:body=>"Feliz ano novo!", :target_url=>"https://app.passaporteweb.com.br", :uuid=>nil, :absolute_url=>nil, :scheduled_to=>"2012-01-01 00:00:00", :sender_data=>nil, :read_at=>nil, :notification_type=>nil, :destination=>"ac3540c7-5453-424d-bdfd-8ef2d9ff78df"})
      expect(notification.destination).to eq("ac3540c7-5453-424d-bdfd-8ef2d9ff78df")
      expect(notification.body).to eq("Feliz ano novo!")
      expect(notification.target_url).to eq("https://app.passaporteweb.com.br")
      expect(notification.scheduled_to).to eq("2012-01-01 00:00:00")
      expect(notification.absolute_url).to be_nil
      expect(notification.sender_data).to be_nil
      expect(notification.read_at).to be_nil
      expect(notification.notification_type).to be_nil
    end
  end

  describe ".find_all", :vcr => true do
    before(:each) do
      PassaporteWeb.configuration.user_token = "f01d30c0a2e878fecc838735560253f9e9395932f5337f40"
    end
    context "on success" do
      it "should return the first 20 notifications for the authenticated user, along with pagination information" do
        data = PassaporteWeb::Notification.find_all

        notifications = data.notifications
        expect(notifications.size).to eq(2)
        expect(notifications.map { |n| n.instance_of?(described_class) }.uniq).to be_truthy
        n1, n2 = notifications
        expect(n1.body).to eq('"oioioi"') # TODO why? was it created like this?
        expect(n2.body).to eq('"oioioisss"')
        expect(n1.uuid).to eq("2ca046be-0178-418d-80ac-3a334c264009")
        expect(n2.uuid).to eq("11f40530-2de0-471d-b1f7-ff39ea21363f")

        meta = data.meta
        expect(meta.limit).to eq(20)
        expect(meta.next_page).to eq(nil)
        expect(meta.prev_page).to eq(nil)
        expect(meta.first_page).to eq(1)
        expect(meta.last_page).to eq(1)
      end
      it "should return notifications for the authenticated user according to params, along with pagination information" do
        data = PassaporteWeb::Notification.find_all(2, 1, nil, true, "newest-first")

        notifications = data.notifications
        expect(notifications.size).to eq(1)
        expect(notifications.map { |n| n.instance_of?(described_class) }.uniq). to be_truthy
        n1 = notifications.first
        expect(n1.body).to eq('"oioioi"') # TODO why? was it created like this?
        expect(n1.uuid).to eq("2ca046be-0178-418d-80ac-3a334c264009")

        meta = data.meta
        expect(meta.limit).to eq(1)
        expect(meta.next_page).to eq(nil)
        expect(meta.prev_page).to eq(1)
        expect(meta.first_page).to eq(1)
        expect(meta.last_page).to eq(2)
      end
    end
    context "on failure" do
      it "400 Bad Request" do
        expect(PassaporteWeb::Notification.find_all(1, 20, nil, true, 'lalala')).to eq({"ordering"=>["Faça uma escolha válida. lalala não está disponível."]})
      end
      it "404 Not Found" do
        expect {
          PassaporteWeb::Notification.find_all(1_000_000)
        }.to raise_error(RestClient::ResourceNotFound)
      end
    end
  end

  describe ".count", :vcr => true do
    before(:each) do
      PassaporteWeb.configuration.user_token = "f01d30c0a2e878fecc838735560253f9e9395932f5337f40"
    end
    context "on success" do
      it "should return count of notifications for the authenticated user" do
        expect(PassaporteWeb::Notification.count).to eq(2)
      end
      it "should return count of notifications for the authenticated user, according to params" do
        expect(PassaporteWeb::Notification.count(true, '2013-04-02')).to eq(2)
      end
    end
    context "on failure" do
      it "it should return an error message if an invalid parameter is sent" do
        expect(PassaporteWeb::Notification.count(false, "lalala")).to eq({"since"=>["Informe uma data/hora válida."]})
      end
    end
  end

  describe "#save", vcr: true do
    context "on create" do
      let(:notification) { described_class.new(body: 'feliz aniversário!', target_url: 'http://pittlandia.net', scheduled_to: '2013-04-19 10:50:19', destination: 'a5868d14-6529-477a-9c6b-a09dd42a7cd2') }
      context "on success" do
        it "should create the Notification on PassaporteWeb, authenticated as the user" do
          PassaporteWeb.configuration.user_token = "f01d30c0a2e878fecc838735560253f9e9395932f5337f40"
          expect(notification).not_to be_persisted
          expect(notification.save).to be_truthy # by default authenticates as the user
          expect(notification).to be_persisted
          expect(notification.uuid).not_to be_nil
          expect(notification.absolute_url).not_to be_nil
          expect(notification.destination).to be_nil # FIXME is this right? shouldn't it be a5868d14-6529-477a-9c6b-a09dd42a7cd2 ???
          expect(notification.scheduled_to).to eq('2013-04-19 00:00:00') # FIXME is this right? shouldn't it be 2013-04-19 10:50:19 ???
          expect(notification.body).to eq('feliz aniversário!')
          expect(notification.target_url).to eq('http://pittlandia.net/') # PW added the trailing slash, WTF?
          expect(notification.sender_data).to eq({"name" => "Rodrigo Martins", "uuid" => "385f5f3c-8d33-4b95-9e0d-e87962985244"})
          expect(notification.read_at).to be_nil
          expect(notification.notification_type).to be_nil
        end
        it "should create the Notification on PassaporteWeb, authenticated as the application" do
          expect(notification).not_to be_persisted
          expect(notification.save('application')).to be_truthy
          expect(notification).to be_persisted
          expect(notification.uuid).not_to be_nil
          expect(notification.absolute_url).not_to be_nil
          expect(notification.destination).to be_nil # FIXME is this right? shouldn't it be a5868d14-6529-477a-9c6b-a09dd42a7cd2 ???
          expect(notification.scheduled_to).to eq('2013-04-19 00:00:00') # FIXME is this right? shouldn't it be 2013-04-19 10:50:19 ???
          expect(notification.body).to eq('feliz aniversário!')
          expect(notification.target_url).to eq('http://pittlandia.net/') # PW added the trailing slash, WTF?
          expect(notification.sender_data).to eq({"name" => "Identity Client", "slug" => "identity_client"})
          expect(notification.read_at).to be_nil
          expect(notification.notification_type).to be_nil
        end
      end
      context "on failure" do
        it "should return false an do nothing if the Notification is already persisted" do
          PassaporteWeb.configuration.user_token = "f01d30c0a2e878fecc838735560253f9e9395932f5337f40"
          notification = described_class.find_all(1,20,nil,true).notifications.last
          expect(notification.save).to be_falsy
        end
        it "should return false and set the errors with the reason for the failure, authenticated as the user" do
          PassaporteWeb.configuration.user_token = "f01d30c0a2e878fecc838735560253f9e9395932f5337f40"
          notification.target_url = 'lalalala'
          expect(notification).not_to be_persisted
          expect(notification.save('user')).to be_falsy
          expect(notification).not_to be_persisted
          expect(notification.uuid).to be_nil
          expect(notification.errors).to eq({"field_errors"=>{"target_url"=>["Informe uma URL válida."]}})
        end
        it "should return false and set the errors with the reason for the failure, authenticated as the application" do
          notification.destination = nil # required field
          expect(notification).not_to be_persisted
          expect(notification.save('application')).to be_falsy
          expect(notification).not_to be_persisted
          expect(notification.uuid).to be_nil
          expect(notification.errors).to eq({"field_errors"=>{"destination"=>["Este campo é obrigatório."]}})
        end
      end
    end
  end

  describe "#read!", vcr: true do
    let(:notification) { described_class.find_all.notifications.last }
    before(:each) do
      PassaporteWeb.configuration.user_token = "3e4470e59d76f748e0081b514da62ed621a893c87facd4a6"
    end
    context "on success" do
      it "should mark the Notification as read" do
        expect(notification.read_at).to be_nil
        expect(notification.read!).to be_truthy
        expect(notification.read_at).not_to be_nil
      end
    end
    context "on failure" do
      it "should return false if the notification is already read" do
        read_notification = described_class.find_all(1,20,nil,true).notifications.detect { |n| !n.read_at.nil? }
        expect(read_notification.read_at).not_to be_nil
        expect(read_notification.read!).to be_falsy
        expect(read_notification.errors).to eq({message: 'notification already read'})
      end
    end
  end

  describe "#destroy" do
    let(:notification) { described_class.new(body: 'novinha', destination: 'a5868d14-6529-477a-9c6b-a09dd42a7cd2', scheduled_to: '2013-04-06') } # 2.days.from_now
    it "should return false if the record is not persisted" do
      expect(notification.destroy).to be_falsy
      expect(notification.errors).to eq({message: 'notification not persisted yet'})
    end
    it "should destroy the notification on PassaporteWeb if the notification has not been read and is scheduled", vcr: true do
      expect(notification.save('application')).to be_truthy
      expect(notification.read_at).to be_nil
      expect(notification.scheduled_to).to eq("2013-04-06 00:00:00")
      expect(notification.destroy).to be_truthy
    end
    it "should not exclude non-scheduled notification", vcr: true do
      notification.scheduled_to = nil
      expect(notification.save('application')).to be_truthy
      expect(notification.destroy).to be_falsy
      expect(notification.errors).to eq("Only scheduled notifications can be deleted via API")
    end
  end

end
