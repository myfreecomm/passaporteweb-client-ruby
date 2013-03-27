# encoding: utf-8
module PassaporteWeb

  class Account
    ATTRIBUTES = [:plan_slug, :expiration, :identity, :roles, :member_uuid, :role, :include_expired_accounts, :name, :members_data, :url, :service_data, :account_data, :add_member_url]
    UPDATABLE_ATTRIBUTES = [:plan_slug, :expiration]

    attr_accessor *UPDATABLE_ATTRIBUTES
    attr_reader *(ATTRIBUTES - UPDATABLE_ATTRIBUTES)
    attr_reader :errors

    def initialize(attributes={})
      set_attributes(attributes)
      @errors = {}
    end

    # GET /organizations/api/accounts/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#get-organizations-api-accounts
    def self.find_all(page=1, limit=20)
      response = Http.get("/organizations/api/accounts/?page=#{page}&limit=#{limit}")
      MultiJson.decode(response.body)
    end

    # GET /organizations/api/accounts/:uuid/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#get-organizations-api-accounts-uuid
    def self.find_by_uuid(uuid=nil)
      if uuid.nil?
        find_all
      else
        response = Http.get("/organizations/api/accounts/#{uuid}/")
        attributes_hash = MultiJson.decode(response.body)
        [] << attributes_hash
      end
    end

    # PUT /organizations/api/accounts/:uuid/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#put-organizations-api-accounts-uuid
    # def save
    # end

    # POST /organizations/api/accounts/:uuid/members/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#post-organizations-api-accounts-uuid-members
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
    rescue *[RestClient::Conflict, RestClient::BadRequest] => e
      p e
      @errors = MultiJson.decode(e.response.body)
      false
    end

    # GET /organizations/api/accounts/:uuid/members/:member_uuid/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#get-organizations-api-accounts-uuid-members-member-uuid
    def self.list_members(uuid=nil, member_uuid=nil)
      raise "The uuid field is required." if uuid.nil?
      raise "The member_uuid field is required." if member_uuid.nil?
      response = Http.get("/organizations/api/accounts/#{uuid}/members/#{member_uuid}/")
      MultiJson.decode(response.body)
    end

    # PUT /organizations/api/accounts/:uuid/members/:member_uuid/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#get-organizations-api-accounts-uuid-members-member-uuid
    def self.update_roles_members(uuid=nil, member_uuid=nil, roles=nil)
      raise "The uuid field is required."        if uuid.nil?
      raise "The member_uuid field is required." if member_uuid.nil?
      raise "The roles field is required."       if roles.nil?
      response = Http.put("/organizations/api/accounts/#{uuid}/members/#{member_uuid}/", roles: roles)
      MultiJson.decode(response.body)
    end

    def attributes
      ATTRIBUTES.inject({}) do |hash, attribute|
        hash[attribute] = self.send(attribute)
        hash
      end
    end

    private

    def set_attributes(hash)
      ATTRIBUTES.each do |attribute|
        instance_variable_set("@#{attribute}".to_sym, hash[attribute.to_s])
      end
    end

    def update_body
      self.attributes.select { |key, value| UPDATABLE_ATTRIBUTES.include?(key) && !value.nil? }
    end

    def body
      self.attributes.select { |key, value| ATTRIBUTES.include?(key) && !value.nil? }
    end

  end

end