class PassaporteWeb::Resources::Base

  def initialize(api)
    @api = api
  end

  protected

  attr_reader :api

  def respond_with_collection(response, naked_klass = entity_klass)
    # response.parsed is an Array
    PassaporteWeb::Entities::Collection.build(response.parsed, naked_klass)
  end

  def respond_with_entity(response, naked_klass = entity_klass)
    # response.parsed is a Hash
    naked_klass.new(response.parsed)
  end

  def base_klass
    @base_klass ||= self.class.name.split("::").last
  end

  def entity_klass
    @entity_klass ||= PassaporteWeb::Entities.const_get(base_klass.to_sym)
  end
end
