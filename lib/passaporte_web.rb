# encoding: utf-8

require 'oauth2'
require 'multi_json'

require "passaporte_web/version"
require "passaporte_web/configuration"

require "passaporte_web/client"
require "passaporte_web/client/application"
require "passaporte_web/client/exception"
require "passaporte_web/client/exception_wrapper"
require "passaporte_web/client/identity"
require "passaporte_web/client/oauth"

require "passaporte_web/entities"
require "passaporte_web/entities/base"

require "passaporte_web/entities/profile"
require "passaporte_web/entities/profile/professional_info"
require "passaporte_web/entities/profile/contacts"
require "passaporte_web/entities/profile/emails"

require "passaporte_web/entities/sign_up"

require "passaporte_web/resources"
require "passaporte_web/resources/base"
require "passaporte_web/resources/profile"
require "passaporte_web/resources/sign_up"
require "passaporte_web/resources/widget"

module PassaporteWeb
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end
end
