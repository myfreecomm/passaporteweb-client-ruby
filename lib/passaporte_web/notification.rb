# encoding: utf-8
module PassaporteWeb

  # Represents the NOTIFICATIONS of PassaporteWeb.
  class Notification
    ATTRIBUTES = [:destination, :body, :target_url, :scheduled_to]

    attr_reader *(ATTRIBUTES)
    attr_reader :errors

    # List the Notifications of User.
    #
    # All params are optional
    # Params:
    #   show_read -> Consider notifications read   , value default: false
    #   since     -> Date Start
    #   page      -> Pages of Result               , value default: 1
    #   limit     -> Limit number of notifications , value default: 20
    #   ordering  -> Ordering the notifications    , value default: oldest-first
    #
    # API method: <tt>GET /notifications/api/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/notificacao.html#get-notifications-api
    def self.list(show_read=false, since="", page=1, limit=20, ordering="oldest-first")
      response = Http.get("/notifications/api/?show_read=#{show_read}&since=#{since}&page=#{Integer(page)}&limit=#{Integer(limit)}&ordering=#{ordering}", nil, 'user')
      MultiJson.decode(response.body)
    rescue *[RestClient::Conflict, RestClient::BadRequest] => e
      @errors = MultiJson.decode(e.response.body)
      [@errors]
    end

    # List the Notifications of User.
    #
    # All params are optional
    # Params:
    #   show_read -> Consider notifications read   , value default: false
    #   since     -> Date Start
    #
    # API method: <tt>GET /notifications/api/count/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/notificacao.html#get-notifications-api-count
    def self.count(show_read=false, since="")
      response = Http.get("/notifications/api/count/?show_read=#{show_read}&since=#{since}", nil, 'user')
      MultiJson.decode(response.body)
    rescue *[RestClient::Conflict, RestClient::BadRequest, RestClient::Unauthorized] => e
      @errors = MultiJson.decode(e.response.body)
      [@errors]
    end

    # Instanciates a new Notification with the supplied attributes.
    #
    # Example:
    #
    #   notification = PassaporteWeb::Notification.new(
    #     destination: "ac3540c7-5453-424d-bdfd-8ef2d9ff78df",
    #     body: "Feliz ano novo!",
    #     target_url: "https://app.passaporteweb.com.br",
    #     scheduled_to: "2012-01-01 00:00:00"
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

    private

    def set_attributes(hash)
      ATTRIBUTES.each do |attribute|
        value = hash[attribute.to_s] if hash.has_key?(attribute.to_s)
        value = hash[attribute.to_sym] if hash.has_key?(attribute.to_sym)
        instance_variable_set("@#{attribute}".to_sym, value)
      end
      @persisted = true
    end

  end

end
