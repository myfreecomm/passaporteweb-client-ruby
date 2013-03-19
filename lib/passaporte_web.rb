# encoding: utf-8

require 'rest_client'
require 'multi_json'

require "passaporte_web/version"
require "passaporte_web/configuration"

module PassaporteWeb

  def self.configuration
    @configuration ||=  Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

end
