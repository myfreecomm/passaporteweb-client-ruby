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
    def self.find(page=1, limit=20)
      response = Http.get("/organizations/api/accounts/?page=#{page}&limit=#{limit}")
      attributes_hash = MultiJson.decode(response.body)
      self.new(attributes_hash)
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

    # PUT  /profile/api/info/:uuid/
    # https://app.passaporteweb.com.br/static/docs/perfil.html#put-profile-api-info-uuid
    # POST /accounts/api/create/
    # https://app.passaporteweb.com.br/static/docs/cadastro_e_auth.html#post-accounts-api-create
    def save
      # TODO validar atributos?
      if !self.uuid.nil?
        response = Http.put("/profile/api/info/#{uuid}/", update_body)
      else
        response = Http.post("/accounts/api/create/", body)
      end
      raise "unexpected response: #{response.code} - #{response.body}" unless response.code == 200
      attributes_hash = MultiJson.decode(response.body)
      set_attributes(attributes_hash)
      @errors = {}
      true
    rescue *[RestClient::Conflict, RestClient::BadRequest] => e
      @errors = MultiJson.decode(e.response.body)
      false
    end

    private

    def set_attributes(hash)
      binding.pry
      ATTRIBUTES.each do |attribute|
        puts "*"*80
        puts attribute
        puts "*"*80
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