# encoding: utf-8
module PassaporteWeb

  class Profile
    ATTRIBUTES = [:accounts, :birth_date, :country, :cpf, :email, :first_name, :gender, :is_active, :language, :last_name, :nickname, :notifications, :send_myfreecomm_news, :send_partner_news, :services, :timezone, :update_info_url, :uuid]
    UPDATABLE_ATTRIBUTES = [:first_name, :last_name, :nickname, :cpf, :birth_date, :gender, :send_myfreecomm_news, :send_partner_news, :country, :language, :timezone]

    attr_accessor *UPDATABLE_ATTRIBUTES
    attr_reader *(ATTRIBUTES - UPDATABLE_ATTRIBUTES)
    attr_reader :errors

    # GET /profile/api/info/:uuid/
    # https://app.passaporteweb.com.br/static/docs/perfil.html#get-profile-api-info-uuid
    def self.find(uuid)
      response = Http.get("/profile/api/info/#{uuid}/")
      attributes_hash = MultiJson.decode(response.body)
      self.new(attributes_hash)
    end

    # GET /profile/api/info/?email=:email
    # https://app.passaporteweb.com.br/static/docs/perfil.html#get-profile-api-info-email-email
    def self.find_by_email(email)
      response = Http.get("/profile/api/info/", email: email)
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

    def ==(other)
      self.uuid == other.uuid
    end

    def ===(other)
      self.object_id == other.object_id
    end

    # PUT /profile/api/info/:uuid/
    # https://app.passaporteweb.com.br/static/docs/perfil.html#put-profile-api-info-uuid
    def save
      # TODO validar atributos?
      response = Http.put("/profile/api/info/#{uuid}/", update_body)
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
      # TODO @accounts é um array de hashes
      # TODO @services é um hash
      # TODO @notifications é um hash
      ATTRIBUTES.each do |attribute|
        instance_variable_set("@#{attribute}".to_sym, hash[attribute.to_s])
      end
    end

    def update_body
      self.attributes.select { |key, value| UPDATABLE_ATTRIBUTES.include?(key) && !value.nil? }
    end

  end

end
