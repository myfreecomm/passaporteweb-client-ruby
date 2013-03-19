# encoding: utf-8
require 'recursive-open-struct'
module PassaporteWeb

  class Profile
    ATTRIBUTES = [:accounts, :birth_date, :country, :cpf, :email, :first_name, :gender, :is_active, :language, :last_name, :nickname, :notifications, :send_myfreecomm_news, :send_partner_news, :services, :timezone, :update_info_url, :uuid]
    UPDATABLE_ATTRIBUTES = [:first_name, :last_name, :nickname, :cpf, :birth_date, :gender, :send_myfreecomm_news, :send_partner_news, :country, :language, :timezone]

    attr_accessor *UPDATABLE_ATTRIBUTES
    attr_reader *(ATTRIBUTES - UPDATABLE_ATTRIBUTES)

    # GET /profile/api/info/:uuid/
    # https://app.passaporteweb.com.br/static/docs/perfil.html#get-profile-api-info-uuid
    # TOSPEC
    def self.find(uuid)
      response = RestClient.get(
        "#{PassaporteWeb.configuration.url}/profile/api/info/#{uuid}/",
        params: {},
        authorization: PassaporteWeb.configuration.application_credentials,
        content_type: :json,
        accept: :json,
        user_agent: "PassaporteWeb Ruby Client v#{PassaporteWeb::VERSION}" # TODO ser configurável
      )
      attributes_hash = MultiJson.decode(response.body)
      self.new(attributes_hash)
    end

    # GET /profile/api/info/?email=:email
    # https://app.passaporteweb.com.br/static/docs/perfil.html#get-profile-api-info-email-email
    # TOSPEC
    def self.find_by_email(email)
      response = RestClient.get(
        "#{PassaporteWeb.configuration.url}/profile/api/info/",
        params: {email: email},
        authorization: PassaporteWeb.configuration.application_credentials,
        content_type: :json,
        accept: :json,
        user_agent: "PassaporteWeb Ruby Client v#{PassaporteWeb::VERSION}" # TODO ser configurável
      )
      attributes_hash = MultiJson.decode(response.body)
      self.new(attributes_hash)
    end

    def initialize(attributes={})
      set_attributes(attributes)
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
    # TOSPEC
    def save
      # TODO validar atributos?
      response = RestClient.put(
        "#{PassaporteWeb.configuration.url}/profile/api/info/#{uuid}/",
        update_body,
        params: {},
        authorization: PassaporteWeb.configuration.application_credentials,
        content_type: :json,
        accept: :json,
        user_agent: "PassaporteWeb Ruby Client v#{PassaporteWeb::VERSION}" # TODO ser configurável
      )
      if response.code == 200
        attributes_hash = MultiJson.decode(response.body)
        set_attributes(attributes_hash)
        true
      else
        false # TODO mostrar erros
      end
    end

    private

    def set_attributes(hash)
      @accounts = hash['accounts'] # TODO é um array de hashes
      @birth_date = hash['birth_date']
      @country = hash['country']
      @cpf = hash['cpf']
      @email = hash['email']
      @first_name = hash['first_name']
      @gender = hash['gender']
      @is_active = hash['is_active']
      @language = hash['language']
      @last_name = hash['last_name']
      @nickname = hash['nickname']
      @notifications = hash['notifications'] # TODO é um hash
      @send_myfreecomm_news = hash['send_myfreecomm_news']
      @send_partner_news = hash['send_partner_news']
      @services = hash['services'] # TODO é um hash
      @timezone = hash['timezone']
      @update_info_url = hash['update_info_url']
      @uuid = hash['uuid']
    end

    # TOSPEC ?
    def update_body
      hash = self.attributes.select { |key, value| UPDATABLE_ATTRIBUTES.include?(key) && !value.nil? }
      MultiJson.encode(hash)
    end

  end

end
