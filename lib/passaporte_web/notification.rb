# encoding: utf-8
module PassaporteWeb

  # Represents the Notifications of PassaporteWeb.
  class Notification
    include Attributable

    ATTRIBUTES = [:body, :target_url, :uuid, :absolute_url, :scheduled_to, :sender_data, :read_at, :notification_type, :destination]
    CREATABLE_ATTRIBUTES = [:body, :target_url, :scheduled_to, :destination]
    UPDATEABLE_ATTRIBUTES = []

    attr_accessor *(CREATABLE_ATTRIBUTES + UPDATEABLE_ATTRIBUTES)
    attr_reader *(ATTRIBUTES - (CREATABLE_ATTRIBUTES + UPDATEABLE_ATTRIBUTES))
    attr_reader :errors

    # Finds all Notifications destined to the authenticated user, paginated. By default returns 20 notifications
    # per request, starting at "page" 1. Returns an OpenStruct object with two attributes <tt>notifications</tt>
    # and <tt>meta</tt>. <tt>notifications</tt> is an array of Notification instances or an empty array
    # if no Notifications are found. <tt>meta</tt> is an OpenStruct object with information about limit and available
    # pagination values, to use in subsequent calls to <tt>.find_all</tt>. Raises a <tt>RestClient::ResourceNotFound</tt>
    # exception if the requested page does not exist. All method parameters are optional.
    #
    # API method: <tt>GET /notifications/api/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/notificacao.html#get-notifications-api
    #
    # Example:
    #   data = PassaporteWeb::Notification.find_all
    #   data.notifications # => [notification1, notification2, ...]
    #   data.meta # => #<OpenStruct limit=20, next_page=2, prev_page=nil, first_page=1, last_page=123>
    #   data.meta.limit      # => 20
    #   data.meta.next_page  # => 2
    #   data.meta.prev_page  # => nil
    #   data.meta.first_page # => 1
    #   data.meta.last_page  # => 123
    def self.find_all(page=1, limit=20, since=nil, show_read=false, ordering="oldest-first")
      since = since.strftime('%Y-%m-%d') if since && since.respond_to?(:strftime)
      params = {
        page: page, limit: limit, since: since, show_read: show_read, ordering: ordering
      }.reject { |k,v| v.nil? || v.to_s.empty? }
      response = Http.get("/notifications/api/", params, 'user')
      raw_data = MultiJson.decode(response.body)
      result_hash = {}
      result_hash[:notifications] = raw_data.map { |hash| load_notification(hash) }
      result_hash[:meta] = PassaporteWeb::Helpers.meta_links_from_header(response.headers[:link])
      PassaporteWeb::Helpers.convert_to_ostruct_recursive(result_hash)
    rescue *[RestClient::BadRequest] => e
      MultiJson.decode(e.response.body)
    end

    # Returns the number of notifications available for the authenticated user. All parameters
    # are optional.
    #
    # API method: <tt>GET /notifications/api/count/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/notificacao.html#get-notifications-api-count
    def self.count(show_read=false, since=nil)
      since = since.strftime('%Y-%m-%d') if since && since.respond_to?(:strftime)
      params = {
        since: since, show_read: show_read
      }.reject { |k,v| v.nil? || v.to_s.empty? }
      response = Http.get("/notifications/api/count/", params, 'user')
      data = MultiJson.decode(response.body)
      Integer(data['count'])
    rescue *[RestClient::BadRequest] => e
      MultiJson.decode(e.response.body)
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
    # TOSPEC
    def initialize(attributes={})
      set_attributes(attributes)
      @errors = {}
    end

    # TODOC
    #
    # API methods:
    # * <tt>POST /notifications/api/</tt> (on create)
    # * <tt>PUT /notifications/api/:uuid/</tt> (on update)
    #
    # API documentation:
    # * https://app.passaporteweb.com.br/static/docs/notificacao.html#post-notifications-api
    # * https://app.passaporteweb.com.br/static/docs/notificacao.html#put-notifications-api-uuid
    # TOSPEC
    # TOSPEC
    def save(auth_type='user')
      self.persisted? ? update : create(auth_type)
    end

    # TODOC
    #
    # API method: <tt>DELETE /notifications/api/:uuid/</tt>
    #
    # API documentation: https://app.passaporteweb.com.br/static/docs/notificacao.html#delete-notifications-api-uuid
    # TOSPEC
    def destroy
      return false unless self.persisted?
      response = Http.delete('/notifications/api/:uuid/')
      raise "unexpected response: #{response.code} - #{response.body}" unless response.code == 204
      @errors = {}
      @persisted = false
      @destroyed = true
      true
    end

    # Returns a hash with all attribures of the Notification.
    def attributes
      ATTRIBUTES.inject({}) do |hash, attribute|
        hash[attribute] = self.send(attribute)
        hash
      end
    end

    def persisted?
      @persisted == true && !self.uuid.nil?
    end

    def destroyed?
      @destroyed == true
    end

    private

    def create(auth_type)
      # TODO validar atributos?
      response = Http.post(
        '/notifications/api/',
        create_body,
        {},
        auth_type
      )
      raise "unexpected response: #{response.code} - #{response.body}" unless response.code == 201
      attributes_hash = MultiJson.decode(response.body)
      set_attributes(attributes_hash)
      @persisted = true
      @errors = {}
      true
    rescue *[RestClient::BadRequest] => e
      @persisted = false
      @errors = MultiJson.decode(e.response.body)
      false
    end

    def update
      # TODO validar atributos?
      response = Http.put(
        "/notifications/api/#{self.uuid}/",
        {},
        {},
        'user'
      )
      raise "unexpected response: #{response.code} - #{response.body}" unless response.code == 200
      attributes_hash = MultiJson.decode(response.body)
      set_attributes(attributes_hash)
      @errors = {}
      true
    rescue *[RestClient::BadRequest] => e
      @errors = MultiJson.decode(e.response.body)
      false
    end

    def create_body
      self.attributes.select { |key, value| CREATABLE_ATTRIBUTES.include?(key) && (!value.nil? && !value.to_s.empty?) }
    end

    def self.load_notification(attributes)
      notification = self.new(attributes)
      notification.instance_variable_set(:@persisted, true)
      notification
    end

  end

end
