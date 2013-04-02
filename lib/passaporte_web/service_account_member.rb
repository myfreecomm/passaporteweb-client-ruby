# encoding: utf-8
module PassaporteWeb

  # Represents the membership of an Identity within a ServiceAccount on PassaporteWeb.
  class ServiceAccountMember

    attr_accessor :roles
    attr_reader :service_account, :identity
    attr_reader :errors

    # Instanciates a new ServiceAccountMember to represent the membership of the supplied Identity in
    # the supplied ServiceAccount. The <tt>roles</tt> attribute should be an array of strings. Any
    # value is accepted, only 'owner' is reserved. By default uses only the value of 'user'.
    def initialize(service_account, identity, roles=['user'])
      @service_account = service_account
      @identity = identity
      @roles = roles
      @membership_details_url = nil
      @errors = {}
    end

    # Finds the membership relation between the supplied Identity in the supplied ServiceAccount and returns
    # an instance of ServiceAccountMember representing it.
    #
    # Raises a <tt>RestClient::ResourceNotFound</tt> exception if the supplied Identity does not have a
    # membership within the supplied ServiceAccount, or if any of the supplied objects is invalid or
    # not existent.
    #
    # API method: <tt>GET /organizations/api/accounts/:uuid/members/:member_uuid/</tt>
    #
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

    # Returns true if the ServiceAccountMember was loaded from PassaporteWeb or saved there successfully.
    def persisted?
      @persisted == true
    end

    # Returns true if the ServiceAccountMember object has been destroyed (and thus represents a membership
    # no more valid on PassaporteWeb)
    def destroyed?
      @destroyed == true
    end

    def membership_details_url # :nodoc:
      return @membership_details_url if @membership_details_url
      "/organizations/api/accounts/#{self.service_account.uuid}/members/#{self.identity.uuid}/" if persisted?
    end

    # Creates or updates the ServiceAccountMember object on PassaporteWeb. Returns true if successful and false
    # (along with the reason for failure in the #errors method) otherwise.
    #
    # On update, the only attribute that can be changed is the <tt>roles</tt>. This can be set to anything,
    # including 'owner', on update (on create, the 'owner' role is not allowed.)
    #
    # API methods:
    # * <tt>POST /organizations/api/accounts/:uuid/members/</tt> (on create)
    # * <tt>PUT /organizations/api/accounts/:uuid/members/:member_uuid/</tt> (on update)
    #
    # API documentation:
    # * https://app.passaporteweb.com.br/static/docs/account_manager.html#post-organizations-api-accounts-uuid-members
    # * https://app.passaporteweb.com.br/static/docs/account_manager.html#put-organizations-api-accounts-uuid-members-member-uuid
    def save
      self.persisted? ? update : create
    end

    # Destroys the membership relation between a Identity and a ServiceAccount, e.g. the Identity no longer will be a
    # member of the ServiceAccount. Returns true if successful of false (along with the reason for failure in the #errors
    # method) otherwise.
    #
    # If the member has a 'owner' role, than the membership can not be destroyed.
    #
    # API method: <tt>DELETE /organizations/api/accounts/:uuid/members/:member_uuid/</tt>
    #
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
