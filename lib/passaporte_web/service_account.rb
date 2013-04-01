# encoding: utf-8
module PassaporteWeb

  class ServiceAccount
    ATTRIBUTES = [:plan_slug, :expiration, :identity, :roles, :member_uuid, :role, :include_expired_accounts, :name, :members_data, :url, :service_data, :account_data, :add_member_url]
    UPDATABLE_ATTRIBUTES = [:plan_slug, :expiration]

    attr_accessor *UPDATABLE_ATTRIBUTES
    attr_reader *(ATTRIBUTES - UPDATABLE_ATTRIBUTES)
    attr_reader :errors

    def initialize(attributes={})
      set_attributes(attributes)
      @errors = {}
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
      result_hash[:service_accounts] = raw_accounts.map { |raw_account| self.new(raw_account) }
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
      self.new(attributes_hash)
    end

    # PUT /organizations/api/accounts/:uuid/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#put-organizations-api-accounts-uuid
    # TODO review
    # def save
    # end

    # POST /organizations/api/accounts/:uuid/members/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#post-organizations-api-accounts-uuid-members
    # TODO review
    def self.save_user(uuid, identity, roles=nil)
      # TODO validar atributos?
      raise "The uuid field is required." if uuid.nil?
      raise "The identity field is required." if identity.nil?
      members = {}
      members["identity"] = identity
      members["roles"]    = roles unless roles.nil?
      response = Http.post("/organizations/api/accounts/#{uuid}/members/", members)
      raise "unexpected response: #{response.code} - #{response.body}" unless response.code == 200
      @errors = {}
      true
    rescue *[RestClient::Conflict, RestClient::BadRequest, RestClient::ResourceNotFound] => e
      @errors = MultiJson.decode(e.response.body)
      false
    end

    # GET /organizations/api/accounts/:uuid/members/:member_uuid/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#get-organizations-api-accounts-uuid-members-member-uuid
    # TODO review
    def self.list_members(uuid=nil, member_uuid=nil)
      raise "The uuid field is required." if uuid.nil?
      raise "The member_uuid field is required." if member_uuid.nil?
      response = Http.get("/organizations/api/accounts/#{uuid}/members/#{member_uuid}/")
      MultiJson.decode(response.body)
    end

    # PUT /organizations/api/accounts/:uuid/members/:member_uuid/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#get-organizations-api-accounts-uuid-members-member-uuid
    # TODO review
    def self.update_roles_members(uuid=nil, member_uuid=nil, roles=nil)
      raise "The uuid field is required."        if uuid.nil?
      raise "The member_uuid field is required." if member_uuid.nil?
      raise "The roles field is required."       if roles.nil?
      response = Http.put("/organizations/api/accounts/#{uuid}/members/#{member_uuid}/", roles: roles)
      MultiJson.decode(response.body)
    end

    # DELETE /organizations/api/accounts/:uuid/members/:member_uuid/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#delete-organizations-api-accounts-uuid-members-member-uuid
    # TODO review
    def self.delete_membership(uuid=nil, member_uuid=nil)
      raise "The uuid field is required."        if uuid.nil?
      raise "The member_uuid field is required." if member_uuid.nil?
      Http.delete("/organizations/api/accounts/#{uuid}/members/#{member_uuid}/")
      true
    rescue *[RestClient::Conflict, RestClient::BadRequest, RestClient::ResourceNotFound] => e
      @errors = MultiJson.decode(e.response.body)
      false
    end

    # GET /organizations/api/identities/:uuid/accounts/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#get-organizations-api-identities-uuid-accounts
    # TODO review
    def self.list_accounts_user(uuid=nil, role=nil, include_expired_accounts=false)
      raise "The uuid field is required."        if uuid.nil?
      param = []
      param << "role=#{role}" if role.nil?
      param << "include_expired_accounts=#{include_expired_accounts}"
      response = Http.get("/organizations/api/identities/#{uuid}/accounts/#{'?'+param.join('&')}")
      MultiJson.decode(response.body)
    end

    # POST /organizations/api/identities/:uuid/accounts/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#post-organizations-api-identities-uuid-accounts
    # TODO review
    def self.new_account_user(uuid=nil, uuid_user=nil, name=nil, plan_slug='passaporteweb-client-ruby', expiration=nil)
      raise "The uuid field is required." if uuid.nil?
      raise "The fields uuid_user and name are required." if uuid_user.nil? and name.nil?
      account = {}
      account["plan_slug"]  = plan_slug
      account["uuid_user"]  = uuid_user unless uuid_user.nil?
      account["name"]       = name unless name.nil?
      account["expiration"] = expiration unless expiration.nil?
      response = Http.post("/organizations/api/identities/#{uuid}/accounts/", account)
      raise "unexpected response: #{response.code} - #{response.body}" unless response.code == 201
      @errors = {}
      true
    rescue *[RestClient::Conflict, RestClient::BadRequest, RestClient::ResourceNotFound] => e
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

    private

    def set_attributes(hash)
      # TODO @account_data é um hash
      # TODO @service_data é um hash
      # TODO @members_data é um array de hashes
      ATTRIBUTES.each do |attribute|
        value = hash[attribute.to_s] if hash.has_key?(attribute.to_s)
        value = hash[attribute.to_sym] if hash.has_key?(attribute.to_sym)
        instance_variable_set("@#{attribute}".to_sym, value)
      end
      @persisted = true
    end

  end

end
