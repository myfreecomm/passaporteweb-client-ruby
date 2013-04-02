# encoding: utf-8
module PassaporteWeb

  # Represents an Identity on PassaporteWeb, i.e. a person. When you sign up for PassaporteWeb, your 'account'
  # there is an Identity.
  class Identity
    include Attributable

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
    # If <tt>include_expired_accounts</tt> is passed as <tt>true</tt>, brings information about all
    # accounts the Identity is related, regardless of the account's expiration date.
    #
    # If <tt>include_other_services</tt> is passed as <tt>true</tt>, brings information about accounts
    # of all services the Identity is related to (not just the current logged in service / application).
    #
    # API method: <tt>/accounts/api/identities/:uuid/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/usuarios.html#get-accounts-api-identities-uuid
    def self.find(uuid, include_expired_accounts=false, include_other_services=false)
      response = Http.get(
        "/accounts/api/identities/#{uuid}/",
        {include_expired_accounts: include_expired_accounts, include_other_services: include_other_services}
      )
      attributes_hash = MultiJson.decode(response.body)
      self.new(attributes_hash)
    end

    # Finds an Identity by it's email (emails are unique on PassaporteWeb). Returns the Identity instance
    # with all fields set if successful. Raises a <tt>RestClient::ResourceNotFound</tt> exception if no
    # Identity exists with the supplied email.
    #
    # If <tt>include_expired_accounts</tt> is passed as <tt>true</tt>, brings information about all
    # accounts the Identity is related, regardless of the account's expiration date.
    #
    # If <tt>include_other_services</tt> is passed as <tt>true</tt>, brings information about accounts
    # of all services the Identity is related to (not just the current logged in service / application).
    #
    # API method: <tt>GET /accounts/api/identities/?email=:email</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/usuarios.html#get-accounts-api-identities-email-email
    def self.find_by_email(email, include_expired_accounts=false, include_other_services=false)
      response = Http.get(
        "/accounts/api/identities/",
        {email: email, include_expired_accounts: include_expired_accounts, include_other_services: include_other_services}
      )
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
    # API methods:
    # * <tt>POST /accounts/api/create/</tt> (on create)
    # * <tt>PUT /accounts/api/identities/:uuid/</tt> (on update)
    #
    # API documentation:
    # * https://app.passaporteweb.com.br/static/docs/usuarios.html#post-accounts-api-create
    # * https://app.passaporteweb.com.br/static/docs/usuarios.html#get-accounts-api-identities-email-email
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
      Http.put("/accounts/api/identities/#{self.uuid}/", update_body)
    end

    def update_body
      self.attributes.select { |key, value| UPDATABLE_ATTRIBUTES.include?(key) && !value.nil? }
    end

    def create_body
      self.attributes.select { |key, value| CREATABLE_ATTRIBUTES.include?(key) && !value.nil? }
    end

  end

end
