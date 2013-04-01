# encoding: utf-8
module PassaporteWeb

  # Represents an Identity on PassaporteWeb, i.e. a person. When you sign up for PassaporteWeb, your 'account'
  # there is an Identity.
  class Identity
    ATTRIBUTES = [:accounts, :birth_date, :country, :cpf, :email, :first_name, :gender, :is_active, :language, :last_name, :nickname, :notifications, :send_myfreecomm_news, :send_partner_news, :services, :timezone, :update_info_url, :uuid, :password, :password2, :must_change_password, :inhibit_activation_message, :tos]
    UPDATABLE_ATTRIBUTES = [:first_name, :last_name, :nickname, :cpf, :birth_date, :gender, :send_myfreecomm_news, :send_partner_news, :country, :language, :timezone]
    CREATABLE_ATTRIBUTES = *(UPDATABLE_ATTRIBUTES + [:email, :password, :password2, :must_change_password, :tos])

    attr_accessor *UPDATABLE_ATTRIBUTES
    attr_reader *(ATTRIBUTES - UPDATABLE_ATTRIBUTES)
    attr_reader :errors

    # Finds an Identity by it's UUID. Returns the Identity instance with all fields set if successful.
    # Raises a <tt>RestClient::ResourceNotFound</tt> exception if no Identity exists with the supplied
    # UUID.
    #
    # API method: <tt>GET /profile/api/info/:uuid/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/perfil.html#get-profile-api-info-uuid
    def self.find(uuid)
      require "passaporte_web/pw.rb"
      attributes_hash = PW.find("/profile/api/info/#{uuid}/", Http)
      self.new(attributes_hash)
    end

    # Finds an Identity by it's email (emails are unique on PassaporteWeb). Returns the Identity instance
    # with all fields set if successful. Raises a <tt>RestClient::ResourceNotFound</tt> exception if no
    # Identity exists with the supplied email.
    #
    # API method: <tt>GET /profile/api/info/?email=:email</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/perfil.html#get-profile-api-info-email-email
    def self.find_by_email(email)
      response = Http.get("/profile/api/info/", email: email)
      attributes_hash = MultiJson.decode(response.body)
      self.new(attributes_hash)
    end

    # Instanciates a new Identity with the supplied attributes. Only the attributes listed
    # on <tt>Identity::CREATABLE_ATTRIBUTES</tt> are used when creating an Identity and
    # on <tt>Identity::UPDATABLE_ATTRIBUTES</tt> are used when updating an Identity.
    #
    # Example:
    #
    #   identity = PassaporteWeb::Identity.new(
    #     email: 'fulano@detal.com.br',
    #     password: '123456',
    #     password2: '123456',
    #     must_change_password: false,
    #     tos: true,
    #     first_name: 'Fulano',
    #     last_name: 'de Tal',
    #     nickname: 'Fulaninho',
    #     cpf: '342.766.570-40',
    #     birth_date: '1983-04-19',
    #     gender: 'M',
    #     send_myfreecomm_news: true,
    #     send_partner_news: false,
    #     country: 'Brasil',
    #     language: 'pt_BR',
    #     timezone: 'GMT-3'
    #   )
    def initialize(attributes={})
      set_attributes(attributes)
      @errors = {}
    end

    # Returns a hash with all attribures of the identity.
    def attributes
      ATTRIBUTES.inject({}) do |hash, attribute|
        hash[attribute] = self.send(attribute)
        hash
      end
    end

    # Compares one Identity with another, returns true if they have the same UUID.
    def ==(other)
      self.uuid == other.uuid
    end

    # Returns true if both Identity are the same object.
    def ===(other)
      self.object_id == other.object_id
    end

    # Saves the Identity on PassaporteWeb, creating it if new or updating it if existing. Returns true
    # if successfull or false if not. In case of failure, it will fill the <tt>errors</tt> attribute
    # with the reason for the failure to save the object.
    #
    # API methods: <tt>POST /accounts/api/create/</tt> (on create) and <tt>PUT /profile/api/info/:uuid/</tt> (on update)
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/cadastro_e_auth.html#post-accounts-api-create
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/perfil.html#put-profile-api-info-uuid
    #
    # Example:
    #
    #   identity = Identity.find_by_email('foo@bar.com')
    #   identity.save # => true
    #   identity.cpf = '12'
    #   identity.save # => false
    #   identity.errors # => {"cpf" => ["Certifique-se de que o valor tenha no mínimo 11 caracteres (ele possui 2)."]}
    def save
      # TODO validar atributos?
      response = (persisted? ? update : create)
      raise "unexpected response: #{response.code} - #{response.body}" unless response.code == 200
      attributes_hash = MultiJson.decode(response.body)
      set_attributes(attributes_hash)
      @errors = {}
      true
    rescue *[RestClient::Conflict, RestClient::BadRequest] => e
      @errors = MultiJson.decode(e.response.body)
      false
    end

    def persisted?
      !self.uuid.nil? && @persisted == true
    end

    private

    def create
      Http.post("/accounts/api/create/", create_body)
    end

    def update
      Http.put("/profile/api/info/#{self.uuid}/", update_body)
    end

    def set_attributes(hash)
      # TODO @accounts é um array de hashes
      # TODO @services é um hash
      # TODO @notifications é um hash
      ATTRIBUTES.each do |attribute|
        value = hash[attribute.to_s] if hash.has_key?(attribute.to_s)
        value = hash[attribute.to_sym] if hash.has_key?(attribute.to_sym)
        instance_variable_set("@#{attribute}".to_sym, value)
      end
      @persisted = true
    end

    def update_body
      self.attributes.select { |key, value| UPDATABLE_ATTRIBUTES.include?(key) && !value.nil? }
    end

    def create_body
      self.attributes.select { |key, value| CREATABLE_ATTRIBUTES.include?(key) && !value.nil? }
    end

  end

end
