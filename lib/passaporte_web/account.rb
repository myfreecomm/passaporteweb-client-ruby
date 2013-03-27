# encoding: utf-8
module PassaporteWeb

  class Account
    ATTRIBUTES = [:plan_slug, :expiration, :identity, :roles, :member_uuid, :role, :include_expired_accounts, :name, :members_data, :url, :service_data, :account_data, :add_member_url]
    UPDATABLE_ATTRIBUTES = [:plan_slug, :expiration]

    attr_accessor *UPDATABLE_ATTRIBUTES
    attr_reader *(ATTRIBUTES - UPDATABLE_ATTRIBUTES)
    attr_reader :errors

    # GET /organizations/api/accounts/
    # https://app.passaporteweb.com.br/static/docs/account_manager.html#get-organizations-api-accounts
    def self.find_all(page=1, limit=20)
      response = Http.get("/organizations/api/accounts/?page=#{page}&limit=#{limit}")
      attributes_hash = MultiJson.decode(response.body)
      attributes_hash
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

    def initialize(attributes={})
      set_attributes(attributes)
      @errors = {}
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