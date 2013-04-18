# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::IdentityService do
  let(:identity) { PassaporteWeb::Identity.find('5e32f927-c4ab-404e-a91c-b2abc05afb56') }
  let(:mock_identity) { mock('Identity', uuid: 'identity-uuid') }
  let(:identity_service_data_hash) { {:foo => 'bar', 'spam' => :eggs, 'integer' => 2, :float => 3.456, :array => [1, 2.0, 'three', :four], :hash => {oba: 'eba'}} }
  let(:identity_service_data_hash_as_strings) { {"foo"=>"bar", "hash"=>{"oba"=>"eba"}, "spam"=>"eggs", "integer"=>2, "array"=>[1, 2.0, "three", "four"], "float"=>3.456} }

  describe ".new" do
    it "should instanciate an (almost) empty object" do
      identity_service = described_class.new(mock_identity)
      identity_service.attributes.should == {identity: mock_identity, slug: nil, is_active: nil, service_data: nil}
      identity_service.identity.should == mock_identity
      identity_service.slug.should be_nil
      identity_service.is_active.should be_nil
      identity_service.is_active?.should be_false
      identity_service.service_data.should be_nil
      identity_service.errors.should be_empty
      identity_service.should_not be_persisted
    end
    it "should instanciate an object with attributes set" do
      identity_service = described_class.new(mock_identity)
      attributes = {
        "slug" => "identity_client",
        :is_active => true,
        'service_data' => identity_service_data_hash
      }
      identity_service = described_class.new(mock_identity, attributes)
      identity_service.attributes.should == {identity: mock_identity, slug: 'identity_client', is_active: true, service_data: identity_service_data_hash}
      identity_service.identity.should == mock_identity
      identity_service.slug.should == 'identity_client'
      identity_service.is_active.should == true
      identity_service.is_active?.should be_true
      identity_service.service_data.should == identity_service_data_hash
      identity_service.errors.should be_empty
      identity_service.should_not be_persisted
    end
  end

  describe ".find", vcr: true do
    it "should find the IdentityService representing the existing relationship between the Identity and the Service" do
      identity_service = described_class.find(identity, 'identity_client')
      identity_service.should be_instance_of(described_class)
      identity_service.identity.should == identity
      identity_service.slug.should == 'identity_client'
      identity_service.is_active.should == true
      identity_service.is_active?.should be_true
      identity_service.service_data.should be_nil
      identity_service.errors.should be_empty
      identity_service.should be_persisted
    end
    it "should return nil it the Identity does not have a relationship with the Service" do
      other_identity = PassaporteWeb::Identity.find('840df3bd-8414-4085-9920-1937f4b37dd3')
      described_class.find(other_identity, 'identity_client').should be_nil
    end
  end

  describe "#save", vcr: true do
    it "should create the relationship between Identity and Service with extra data" do
      other_identity = PassaporteWeb::Identity.find('840df3bd-8414-4085-9920-1937f4b37dd3')
      attributes = {
        "slug" => "identity_client",
        :is_active => true,
        'service_data' => identity_service_data_hash
      }
      identity_service = described_class.new(other_identity, attributes)
      identity_service.save.should be_true
      identity_service.service_data.should == identity_service_data_hash_as_strings

      identity_service = described_class.find(other_identity, 'identity_client')
      identity_service.service_data.should == identity_service_data_hash_as_strings
    end
    it "should update the relationship between Identity and Service with extra data" do
      identity_service = described_class.find(identity, 'identity_client')
      identity_service.service_data.should be_empty
      identity_service.service_data = identity_service_data_hash
      identity_service.save.should be_true
      identity_service.service_data.should == identity_service_data_hash_as_strings

      identity_service = described_class.find(identity, 'identity_client')
      identity_service.service_data.should == identity_service_data_hash_as_strings
    end
  end

end
