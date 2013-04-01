require 'rest_client'
require 'multi_json'

class PW
  def self.find(url, http)
    response = http.get(url)
    MultiJson.decode(response.body)
  end
end