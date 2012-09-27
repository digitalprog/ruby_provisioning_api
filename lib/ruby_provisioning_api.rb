$:.unshift(File.dirname(__FILE__)) unless ($:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__))))

require 'yaml'
require 'faraday'
require 'nokogiri'
require 'active_support/all'
require 'active_model'

module RubyProvisioningApi
  class << self

    attr_accessor :configuration
    attr_reader :connection

    def new
      RubyProvisioningApi::Connection.new
    end

    # Adds configuration ability to the gem
    def configuration
      @configuration ||= RubyProvisioningApi::Configuration.new.config
    end

    def configure
      yield(configuration)
    end
 
    def connection 
      @connection ||= RubyProvisioningApi::Connection.new
    end

  end
end

require 'ruby_provisioning_api/version'
require 'ruby_provisioning_api/connection'
require 'ruby_provisioning_api/entity'
require 'ruby_provisioning_api/configuration'
require 'ruby_provisioning_api/member'
require 'ruby_provisioning_api/owner'
require 'ruby_provisioning_api/group'
require 'ruby_provisioning_api/user'
require 'ruby_provisioning_api/error'
