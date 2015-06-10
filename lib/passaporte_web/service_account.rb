# encoding: utf-8
module PassaporteWeb

  # Represents a ServiceAccount on PassaporteWeb, which is the 'account' of an Identity within a Service. A
  # Service may have many ServiceAccount s and many Identity ies via it's ServiceAccount s. A Identity may
  # belong to serveral Service s via it's ServiceAccount s.
  class ServiceAccount
    include Attributable

    ATTRIBUTES = [:plan_slug, :expiration, :identity, :roles, :member_uuid, :role, :include_expired_accounts, :name, :members_data, :url, :service_data, :account_data, :add_member_url]
    UPDATABLE_ATTRIBUTES = [:plan_slug, :expiration]

    attr_accessor *UPDATABLE_ATTRIBUTES
    attr_reader *(ATTRIBUTES - UPDATABLE_ATTRIBUTES)
    attr_reader :errors

    def initialize(attributes={})
      set_attributes(attributes)
      @errors = {}
    end

    def uuid
      self.account_data['uuid'] if self.account_data
    end

    # Finds all ServiceAccounts that the current authenticated application has access to, paginated. By default finds
    # 20 ServiceAccounts per request, starting at "page" 1. Returns an OpenStruct object with two attributes
    # <tt>service_accounts</tt> and <tt>meta</tt>. <tt>service_accounts</tt> is an array of ServiceAccount instances or an empty array
    # if no ServiceAccounts are found. <tt>meta</tt> is an OpenStruct object with information about limit and available
    # pagination values, to use in subsequent calls to <tt>.find_all</tt>. Raises a
    # <tt>RestClient::ResourceNotFound</tt> exception if the requested page does not exist.
    #
    # API method: <tt>GET /organizations/api/accounts/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/account_manager.html#get-organizations-api-accounts
    #
    # Example:
    #   data = PassaporteWeb::ServiceAccount.find_all
    #   data.service_accounts # => [account1, account2, ...]
    #   data.meta # => #<OpenStruct limit=20, next_page=2, prev_page=nil, first_page=1, last_page=123>
    #   data.meta.limit      # => 20
    #   data.meta.next_page  # => 2
    #   data.meta.prev_page  # => nil
    #   data.meta.first_page # => 1
    #   data.meta.last_page  # => 123
    def self.find_all(page=1, limit=20)
      response = Http.get("/organizations/api/accounts/?page=#{Integer(page)}&limit=#{Integer(limit)}")
      raw_accounts = MultiJson.decode(response.body)
      result_hash = {}
      result_hash[:service_accounts] = raw_accounts.map { |raw_account| load_service_account(raw_account) }
      result_hash[:meta] = PassaporteWeb::Helpers.meta_links_from_header(response.headers[:link])
      PassaporteWeb::Helpers.convert_to_ostruct_recursive(result_hash)
    end

    # Instanciates an ServiceAccount identified by it's UUID, with all the details. Only service accounts related to the current
    # authenticated application are available. Returns the ServiceAccount instance if successful, or raises a
    # <tt>RestClient::ResourceNotFound</tt> exception if no ServiceAccount exists with that UUID (or if it is not
    # related to the current authenticated application).
    #
    # API method: <tt>GET /organizations/api/accounts/:uuid/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/account_manager.html#get-organizations-api-accounts-uuid
    def self.find(uuid)
      response = Http.get("/organizations/api/accounts/#{uuid}/")
      attributes_hash = MultiJson.decode(response.body)
      load_service_account(attributes_hash)
    end

    # Updates an existing ServiceAccount, changing it's plan_slug and/or expiration date. Returns true
    # if successfull or false if not. In case of failure, it will fill the <tt>errors</tt> attribute
    # with the reason for the failure to save the object.
    #
    # API method: <tt>PUT /organizations/api/accounts/:uuid/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/account_manager.html#put-organizations-api-accounts-uuid
    def save
      # TODO validar atributos?
      response = update
      raise "unexpected response: #{response.code} - #{response.body}" unless response.code == 200
      attributes_hash = MultiJson.decode(response.body)
      set_attributes(attributes_hash)
      @errors = {}
      true
    rescue *[RestClient::Conflict, RestClient::BadRequest] => e
      @errors = MultiJson.decode(e.response.body)
      false
    end

    def attributes
      ATTRIBUTES.inject({}) do |hash, attribute|
        hash[attribute] = self.send(attribute)
        hash
      end
    end

    def persisted?
      @persisted == true
    end

    def activate(identity)
      response = Http.put("/organizations/api/activate/", {slug: self.plan_slug, identity: identity, global_account: self.uuid})
      raise "unexpected response: #{response.code} - #{response.body}" unless response.code == 200
      @errors = {}
      true
    rescue *[RestClient::Conflict, RestClient::BadRequest] => e
      @errors = MultiJson.decode(e.response.body)
      false
    end

    private

    def update
      Http.put("/organizations/api/accounts/#{self.uuid}/", update_body)
    end

    def update_body
      self.attributes.select { |key, value| UPDATABLE_ATTRIBUTES.include?(key) && !value.nil? }
    end

    def self.load_service_account(attributes_hash)
      service_account = self.new(attributes_hash)
      service_account.instance_variable_set(:@persisted, true)
      service_account
    end

  end

end
