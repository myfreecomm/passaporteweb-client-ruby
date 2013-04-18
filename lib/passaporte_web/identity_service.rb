# encoding: utf-8
module PassaporteWeb

  # The IdentityService objct represents the relationship between an Identity and a Service on PassaporteWeb. This
  # is only relevant if you wish to add information (via +service_data+ attribute) about the Identity and Service
  # on PassaporteWeb. It does not mean that the Identity has an ServiceAccount on the Service.
  class IdentityService
    include Attributable

    ATTRIBUTES = [:identity, :slug, :is_active, :service_data]
    UPDATABLE_ATTRIBUTES = [:is_active, :service_data]

    attr_accessor *UPDATABLE_ATTRIBUTES
    attr_reader *(ATTRIBUTES - UPDATABLE_ATTRIBUTES)
    attr_reader :errors

    # Instanciates a new IdentityService object for the supplied Identity. The +slug+ attribute is required. The
    # +service_data+ attribute should be a Hash that will be converted to a JSON object. As so, it should
    # only contain strings, symbols, integers, floats, arrays and hashes (the last two with only the same
    # kind of simple objects).
    #
    # Example:
    #
    #   identity = PassaporteWeb::Identity.find('some-uuid')
    #   PassaporteWeb::IdentityService.new(identity, slug: 'identity_client', is_active: true, service_data: {foo: 'bar'})
    def initialize(identity, attributes={})
      set_attributes(attributes)
      @identity = identity
      @errors = {}
    end

    # Creates or updates the IdentityService. The +service_data+ attribute should be a Hash that will be
    # converted to a JSON object. As so, it should only contain strings, symbols, integers, floats, arrays
    # and hashes (the last two with only the same kind of simple objects).
    #
    # API method: <tt>PUT /accounts/api/service-info/:uuid/:service_slug/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/servicos.html#put-accounts-api-service-info-uuid-service-slug
    def save
      # TODO validar atributos?
      response = Http.put("/accounts/api/service-info/#{identity.uuid}/#{slug}/", save_body)
      raise "unexpected response: #{response.code} - #{response.body}" unless [200,201].include?(response.code)
      attributes_hash = MultiJson.decode(response.body)
      set_attributes(attributes_hash)
      @errors = {}
      @persisted = true
      true
    rescue *[RestClient::Conflict, RestClient::BadRequest] => e
      @errors = MultiJson.decode(e.response.body)
      false
    end

    def persisted?
      @persisted == true
    end

    def is_active?
      @is_active == true
    end

    def attributes
      ATTRIBUTES.inject({}) do |hash, attribute|
        hash[attribute] = self.send(attribute)
        hash
      end
    end

    # Finds the IdentityService representing the relationship of the Identity with the Service. Returns an
    # IdentityService object or nil if no relationship is found.
    #
    # API method: <tt>GET /accounts/api/service-info/:uuid/:service_slug/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/servicos.html#get-accounts-api-service-info-uuid-service-slug
    def self.find(identity, slug)
      response = Http.get("/accounts/api/service-info/#{identity.uuid}/#{slug}/")
      return if response.code == 204
      attributes_hash = MultiJson.decode(response.body)
      load_identity_service(identity, attributes_hash)
    end

    private

    def self.load_identity_service(identity, attributes)
      service = self.new(identity, attributes)
      service.instance_variable_set(:@persisted, true)
      service
    end

    def save_body
      self.attributes.select { |key, value| UPDATABLE_ATTRIBUTES.include?(key) && !value.nil? }
    end

  end

end
