# encoding: utf-8
module PassaporteWeb

  class ServiceAccountMember

    attr_accessor :roles
    attr_reader :service_account, :identity
    attr_reader :errors

    def initialize(service_account, identity, roles=['user'])
      @service_account = service_account
      @identity = identity
      @roles = roles
      @membership_details_url = nil
      @errors = {}
    end

    # API method: GET /organizations/api/accounts/:uuid/members/:member_uuid/
    # API documentation: https://app.passaporteweb.com.br/static/docs/account_manager.html#get-organizations-api-accounts-uuid-members-member-uuid
    def self.find(service_account, identity)
      response = Http.get("/organizations/api/accounts/#{service_account.uuid}/members/#{identity.uuid}/")
      raise "unexpected response: #{response.code} - #{response.body}" unless response.code == 200
      attributes_hash = MultiJson.decode(response.body)
      member = self.new(service_account, identity, attributes_hash['roles'])
      member.instance_variable_set(:@persisted, true)
      member.instance_variable_set(:@destroyed, false)
      member
    end

    def persisted?
      @persisted == true
    end

    def destroyed?
      @destroyed == true
    end

    def membership_details_url
      return @membership_details_url if @membership_details_url
      "/organizations/api/accounts/#{self.service_account.uuid}/members/#{self.identity.uuid}/" if persisted?
    end

    def save
      self.persisted? ? update : create
    end

    # API method: DELETE /organizations/api/accounts/:uuid/members/:member_uuid/
    # API documentation: https://app.passaporteweb.com.br/static/docs/account_manager.html#delete-organizations-api-accounts-uuid-members-member-uuid
    def destroy
      return false unless self.persisted?
      response = Http.delete(self.membership_details_url)
      raise "unexpected response: #{response.code} - #{response.body}" unless response.code == 204
      @errors = {}
      @persisted = false
      @destroyed = true
      true
    rescue *[RestClient::NotAcceptable] => e
      @errors = MultiJson.decode(e.response.body)
      @persisted = true
      @destroyed = false
      false
    end

    private

    # API method: POST /organizations/api/accounts/:uuid/members/
    # API documentation: https://app.passaporteweb.com.br/static/docs/account_manager.html#post-organizations-api-accounts-uuid-members
    def create
      response = Http.post(
        "/organizations/api/accounts/#{self.service_account.uuid}/members/",
        {identity: self.identity.uuid, roles: self.roles}
      )
      raise "unexpected response: #{response.code} - #{response.body}" unless response.code == 200 # doc says 201
      attributes_hash = MultiJson.decode(response.body)
      @membership_details_url = attributes_hash['membership_details_url']
      @errors = {}
      @persisted = true
      true
    rescue *[RestClient::Conflict, RestClient::BadRequest, RestClient::NotAcceptable] => e
      @errors = MultiJson.decode(e.response.body)
      @persisted = false
      false
    end

    # API method: PUT /organizations/api/accounts/:uuid/members/:member_uuid/
    # API documentation: https://app.passaporteweb.com.br/static/docs/account_manager.html#put-organizations-api-accounts-uuid-members-member-uuid
    def update
      response = Http.put(
        self.membership_details_url,
        {roles: self.roles}
      )
      raise "unexpected response: #{response.code} - #{response.body}" unless response.code == 200
      attributes_hash = MultiJson.decode(response.body)
      @errors = {}
      @persisted = true
      true
    rescue *[RestClient::BadRequest, RestClient::NotAcceptable] => e
      @errors = MultiJson.decode(e.response.body)
      @persisted = true
      false
    end

  end

end
