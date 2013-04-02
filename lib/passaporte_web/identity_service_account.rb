# encoding: utf-8
module PassaporteWeb

  # TODOC
  class IdentityServiceAccount

    ATTRIBUTES = [:membership_details_url, :plan_slug, :roles, :url, :expiration, :service_data, :account_data, :add_member_url, :name, :uuid]
    CREATABLE_ATTRIBUTES = [:plan_slug, :expiration, :name, :uuid]

    attr_accessor *CREATABLE_ATTRIBUTES
    attr_reader *(ATTRIBUTES - CREATABLE_ATTRIBUTES)
    attr_reader :errors

    # TODOC
    #
    # API method: <tt>GET /organizations/api/identities/:uuid/accounts/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/account_manager.html#get-organizations-api-identities-uuid-accounts
    # TOSPEC
    def self.find_all(include_expired_accounts=false, role=nil)
      # TODO
    end

    # TODOC
    # TOSPEC
    def initialize(attributes={})
      set_attributes(attributes)
      @errors = {}
    end

    # TODOC
    #
    # API method: <tt>POST /organizations/api/identities/:uuid/accounts/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/account_manager.html#post-organizations-api-identities-uuid-accounts
    # TOSPEC
    def save
      # TODO
    end

    def persisted?
      @persisted == true
    end

  end

end
