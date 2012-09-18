require 'ruby_provisioning_api/version'
require 'ruby_provisioning_api/connection'
require './lib/ruby_provisioning_api/configuration'

require 'faraday'
require 'yaml'

module RubyProvisioningApi
  class << self

    attr_accessor :configuration
    
    attr_reader :root_path
    attr_reader :lib_path

    def new
      puts "Ehi!"
      RubyProvisioningApi::Connection.new
    end

    # private
    def root_path
					@root_path = File.expand_path "..", __FILE__
    end
		  
		  def lib_path
			  @lib_path = File.expand_path "../ruby_provisioning_api", __FILE__
			 end

    # Adds configuration ability to the gem
    def configuration
      @configuration ||= RubyProvisioningApi::Configuration.new
    end

    def configure
      yield(configuration)
    end
 


  end
end