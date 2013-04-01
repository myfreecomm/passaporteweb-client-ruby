require 'rest_client'
require 'multi_json'

class PW
  def self.find(url, http)
    response = http.get(url)
    MultiJson.decode(response.body)
  end

  def self.set_attributes(attributes, hash)
    # TODO @accounts é um array de hashes
    # TODO @services é um hash
    # TODO @notifications é um hash
    attributes.each do |attribute|
      value = hash[attribute.to_s] if hash.has_key?(attribute.to_s)
      value = hash[attribute.to_sym] if hash.has_key?(attribute.to_sym)
      instance_variable_set("@#{attribute}".to_sym, value)
    end
    @persisted = true
  end
end