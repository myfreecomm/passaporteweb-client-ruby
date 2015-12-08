# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::IdentityService do
  let(:identity) { PassaporteWeb::Identity.find('5e32f927-c4ab-404e-a91c-b2abc05afb56') }
  let(:mock_identity) { double('Identity', uuid: 'identity-uuid') }
  let(:identity_service_data_hash) { {:foo => 'bar', 'spam' => :eggs, 'integer' => 2, :float => 3.456, :array => [1, 2.0, 'three', :four], :hash => {oba: 'eba'}} }
  let(:identity_service_data_hash_as_strings) { {"foo"=>"bar", "hash"=>{"oba"=>"eba"}, "spam"=>"eggs", "integer"=>2, "array"=>[1, 2.0, "three", "four"], "float"=>3.456} }

  describe ".new" do
    it "should instanciate an (almost) empty object" do
      identity_service = described_class.new(mock_identity)
      expect(identity_service.attributes).to eq({identity: mock_identity, slug: nil, is_active: nil, service_data: nil})
      expect(identity_service.identity).to eq(mock_identity)
      expect(identity_service.slug).to be_nil
      expect(identity_service.is_active).to be_nil
      expect(identity_service.is_active?).to be_falsy
      expect(identity_service.service_data).to be_nil
      expect(identity_service.errors).to be_empty
      expect(identity_service).not_to be_persisted
    end
    it "should instanciate an object with attributes set" do
      identity_service = described_class.new(mock_identity)
      attributes = {
        "slug" => "identity_client",
        :is_active => true,
        'service_data' => identity_service_data_hash
      }
      identity_service = described_class.new(mock_identity, attributes)
      expect(identity_service.attributes).to eq({identity: mock_identity, slug: 'identity_client', is_active: true, service_data: identity_service_data_hash})
      expect(identity_service.identity).to eq(mock_identity)
      expect(identity_service.slug).to eq('identity_client')
      expect(identity_service.is_active).to eq(true)
      expect(identity_service.is_active?).to be_truthy
      expect(identity_service.service_data).to eq(identity_service_data_hash)
      expect(identity_service.errors).to be_empty
      expect(identity_service).not_to be_persisted
    end
  end

  describe ".find", vcr: true do
    it "should find the IdentityService representing the existing relationship between the Identity and the Service" do
      identity_service = described_class.find(identity, 'identity_client')
      expect(identity_service).to be_instance_of(described_class)
      expect(identity_service.identity).to eq(identity)
      expect(identity_service.slug).to eq('identity_client')
      expect(identity_service.is_active).to be_truthy
      expect(identity_service.is_active?).to be_truthy
      expect(identity_service.service_data).to be_nil
      expect(identity_service.errors).to be_empty
      expect(identity_service).to be_persisted
    end
    it "should return nil it the Identity does not have a relationship with the Service" do
      other_identity = PassaporteWeb::Identity.find('840df3bd-8414-4085-9920-1937f4b37dd3')
      expect(described_class.find(other_identity, 'identity_client')).to be_nil
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
      expect(identity_service.save).to be_truthy
      expect(identity_service.service_data).to eq(identity_service_data_hash_as_strings)

      identity_service = described_class.find(other_identity, 'identity_client')
      expect(identity_service.service_data).to eq(identity_service_data_hash_as_strings)
    end
    it "should update the relationship between Identity and Service with extra data" do
      identity_service = described_class.find(identity, 'identity_client')
      expect(identity_service.service_data).to be_empty
      identity_service.service_data = identity_service_data_hash
      expect(identity_service.save).to be_truthy
      expect(identity_service.service_data).to eq(identity_service_data_hash_as_strings)

      identity_service = described_class.find(identity, 'identity_client')
      expect(identity_service.service_data).to eq(identity_service_data_hash_as_strings)
    end
  end

end
