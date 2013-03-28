# encoding: utf-8

require 'rest_client'
require 'multi_json'

require "passaporte_web/version"
require "passaporte_web/configuration"
require "passaporte_web/http"
require "passaporte_web/helpers"
require "passaporte_web/identity"
require "passaporte_web/service_account"

module PassaporteWeb

  def self.configuration
    @configuration ||=  Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

end
