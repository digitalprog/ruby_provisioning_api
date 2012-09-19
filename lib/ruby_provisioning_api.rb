$:.unshift(File.dirname(__FILE__)) unless ($:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__))))

require 'yaml'
require 'faraday'

module RubyProvisioningApi
  class << self

    attr_accessor :configuration
    attr_reader :connection
    
    attr_reader :root_path
    attr_reader :lib_path

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

    private
    def root_path
          @root_path = File.expand_path "..", __FILE__
    end
      
    def lib_path
      @lib_path = File.expand_path "../ruby_provisioning_api", __FILE__
     end

  end
end

require 'ruby_provisioning_api/version'
require 'ruby_provisioning_api/connection'
require 'ruby_provisioning_api/entity'
require 'ruby_provisioning_api/configuration'
require 'ruby_provisioning_api/group'