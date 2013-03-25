# encoding: utf-8
module PassaporteWeb

  class RegistrationIdentity
    ATTRIBUTES = [:email, :first_name, :last_name, :password, :password2, :must_change_password, :inhibit_activation_message, :cpf, :send_myfreecomm_news, :send_partner_news, :tos]

    attr_reader *(ATTRIBUTES)
    attr_reader :errors

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

    # POST /accounts/api/create/
    # https://app.passaporteweb.com.br/static/docs/cadastro_e_auth.html#post-accounts-api-create
    def save
      response = Http.post("/accounts/api/create/", body)
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
      ATTRIBUTES.each do |attribute|
        instance_variable_set("@#{attribute}".to_sym, hash[attribute.to_s])
      end
    end

    def body
      self.attributes.select { |key, value| ATTRIBUTES.include?(key) && !value.nil? }
    end

  end

end