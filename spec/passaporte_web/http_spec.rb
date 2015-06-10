# encoding: utf-8
require 'spec_helper'

describe PassaporteWeb::Http do

  before(:each) do
    PassaporteWeb.configure do |c|
      c.url = 'https://some/where'
      c.user_agent = 'My Mocking App v1.1'
      c.application_token = 'some-app-token'
      c.application_secret = 'some-app-secret'
      c.user_token = 'some-user-token'
    end
  end

  let(:mock_response) { 'restclient http response' }

  describe ".get" do
    it "should use RestClient.get with the supplied params and common options" do
      RestClient.should_receive(:get).with(
        'https://some/where/foo',
        params: {spam: 'eggs'},
        authorization: 'Basic c29tZS1hcHAtdG9rZW46c29tZS1hcHAtc2VjcmV0',
        content_type: :json,
        accept: :json,
        user_agent: 'My Mocking App v1.1'
      ).and_return(mock_response)
      described_class.get('/foo', spam: 'eggs')
    end
  end

  describe ".custom_auth_get" do
    it "should use RestClient.get with the supplied params and common options, but with the custom authorization" do
      RestClient.should_receive(:get).with(
        'https://some/where/foo',
        params: {spam: 'eggs'},
        authorization: 'Basic am9obkBkb2UuY29tOnRoZWJpcmRpc3RoZXdvcmQ=',
        content_type: :json,
        accept: :json,
        user_agent: 'My Mocking App v1.1'
      ).and_return(mock_response)
      described_class.custom_auth_get('john@doe.com', 'thebirdistheword', '/foo', spam: 'eggs')
    end
  end

  describe ".delete" do
    it "should use RestClient.delete with the supplied params and common options" do
      RestClient.should_receive(:delete).with(
        'https://some/where/foo',
        params: {spam: 'eggs'},
        authorization: 'Basic c29tZS1hcHAtdG9rZW46c29tZS1hcHAtc2VjcmV0',
        content_type: :json,
        accept: :json,
        user_agent: 'My Mocking App v1.1'
      ).and_return(mock_response)
      described_class.delete('/foo', spam: 'eggs')
    end
  end

  describe ".put" do
    it "should use RestClient.get with the supplied params and common options, encoding body as json" do
      RestClient.should_receive(:put).with(
        'https://some/where/foo',
        '{"hello":"world"}',
        params: {spam: 'eggs'},
        authorization: 'Basic c29tZS1hcHAtdG9rZW46c29tZS1hcHAtc2VjcmV0',
        content_type: :json,
        accept: :json,
        user_agent: 'My Mocking App v1.1'
      ).and_return(mock_response)
      described_class.put('/foo', {hello: 'world'}, {spam: 'eggs'})
    end
    it "should use RestClient.get with the supplied params and common options, with body already as json" do
      RestClient.should_receive(:put).with(
        'https://some/where/foo',
        '{"hello":"world"}',
        params: {spam: 'eggs'},
        authorization: 'Basic c29tZS1hcHAtdG9rZW46c29tZS1hcHAtc2VjcmV0',
        content_type: :json,
        accept: :json,
        user_agent: 'My Mocking App v1.1'
      ).and_return(mock_response)
      described_class.put('/foo', '{"hello":"world"}', {spam: 'eggs'})
    end
  end

  describe ".post" do
    it "should use RestClient.post with the supplied params and common options, encoding body as json" do
      RestClient.should_receive(:post).with(
        'https://some/where/foo',
        '{"hello":"world"}',
        params: {},
        authorization: 'Basic c29tZS1hcHAtdG9rZW46c29tZS1hcHAtc2VjcmV0',
        content_type: :json,
        accept: :json,
        user_agent: 'My Mocking App v1.1'
      ).and_return(mock_response)
      described_class.post('/foo', {hello: 'world'})
    end
    it "should use RestClient.post with the supplied params and common options, with body already as json" do
      RestClient.should_receive(:post).with(
        'https://some/where/foo',
        '{"hello":"world"}',
        params: {},
        authorization: 'Basic c29tZS1hcHAtdG9rZW46c29tZS1hcHAtc2VjcmV0',
        content_type: :json,
        accept: :json,
        user_agent: 'My Mocking App v1.1'
      ).and_return(mock_response)
      described_class.post('/foo', '{"hello":"world"}')
    end
  end

end
