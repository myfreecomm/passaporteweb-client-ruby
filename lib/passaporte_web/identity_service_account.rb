# encoding: utf-8
module PassaporteWeb

  # Also represents a ServiceAccount, but uses diffetent API endpoints to list and create them
  # from a existing Identity.
  class IdentityServiceAccount
    include Attributable

    ATTRIBUTES = [:membership_details_url, :plan_slug, :roles, :url, :expiration, :service_data, :account_data, :add_member_url, :name, :uuid]
    CREATABLE_ATTRIBUTES = [:plan_slug, :expiration, :name, :uuid]

    attr_accessor *CREATABLE_ATTRIBUTES
    attr_reader *(ATTRIBUTES - CREATABLE_ATTRIBUTES)
    attr_reader :identity, :errors

    # Finds all service accounts of the supplied Identity on the current authenticated application.
    # Returns an array of IdentityServiceAccount.
    #
    # API method: <tt>GET /organizations/api/identities/:uuid/accounts/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/account_manager.html#get-organizations-api-identities-uuid-accounts
    def self.find_all(identity, include_expired_accounts=false, role=nil, include_other_services=false)
      params = {include_expired_accounts: include_expired_accounts, include_other_services: include_other_services}
      params[:role] = role unless (role.nil? || role.to_s.empty?)
      response = Http.get("/organizations/api/identities/#{identity.uuid}/accounts/", params)
      raw_accounts = MultiJson.decode(response.body)
      raw_accounts.map { |raw_account| load_identity_service_account(identity, raw_account) }
    end

    # Instanciates a new ServiceAccount to be created for the supplied Identity on the current
    # authenticated application. See #save
    def initialize(identity, attributes={})
      set_attributes(attributes)
      @identity = identity
      @persisted = false
      @errors = {}
    end

    def name
      @name || (@account_data.nil? ? nil : @account_data['name'])
    end

    def uuid
      @uuid || (@account_data.nil? ? nil : @account_data['uuid'])
    end

    # Creates a new ServiceAccount for the supplied Identity on the current authenticated application.
    # The supplied Identity will be the ServiceAccount's owner. You should supply either the <tt>name</tt>
    # or the (service account's) <tt>uuid</tt> attribute. If the latter is supplied, the supplied Identity
    # must already be owner of at least one other ServiceAccount on the same group / organization.
    #
    # Returns true in case of success, false otherwise (along with failure reasons on #errors).
    #
    # API method: <tt>POST /organizations/api/identities/:uuid/accounts/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/account_manager.html#post-organizations-api-identities-uuid-accounts
    def save
      # TODO validar atributos?
      response = Http.post("/organizations/api/identities/#{self.identity.uuid}/accounts/", create_body)
      raise "unexpected response: #{response.code} - #{response.body}" unless [200,201].include?(response.code)
      attributes_hash = MultiJson.decode(response.body)
      set_attributes(attributes_hash)
      @persisted = true
      @errors = {}
      true
    rescue *[RestClient::BadRequest] => e
      @persisted = false
      @errors = MultiJson.decode(e.response.body)
      false
    end

    # Returns true if the IdentityServiceAccount exists on PassaporteWeb
    def persisted?
      @persisted == true
    end

    # Returns a hash with all attribures of the IdentityServiceAccount
    def attributes
      ATTRIBUTES.inject({}) do |hash, attribute|
        hash[attribute] = self.send(attribute)
        hash
      end
    end

    private

    def create_body
      self.attributes.select { |key, value| CREATABLE_ATTRIBUTES.include?(key) && !value.nil? }
    end

    def self.load_identity_service_account(identity, attributes={})
      isa = self.new(identity, attributes)
      isa.instance_variable_set(:@persisted, true)
      isa
    end

  end

end
