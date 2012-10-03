# This is the main RbuyProvisioningApi module.
#
module RubyProvisioningApi
  class << self

    attr_writer :configuration
    attr_reader :connection

    # Returns the current configuration of the gem
    #
    # @example Retrieve the configuration of the RubyProvisioningApi gem
    #   RubyProvisioningApi.configuration # => [Configuration]
    #
    # @return [Configuration]
    #
    def configuration
      @configuration ||= RubyProvisioningApi::Configuration.new
    end

    # Adds configuration ability to the gem
    #
    # @example Ruby on rials initializer for the Ruby Provisioning Api gem
    #   RubyProvisioningApi.configure do |config|
    #     config.config_file = "/path/to/file.yml"
    #     config.ca_file = "/path/to/ca_file"
    #   end
    #
    # It's possible to write an initializer to customize the behaviour of the gem. For a list of all the available
    # options see the {Configuration} class
    #
    def configure
      yield(configuration)
    end

    def connection
      @connection ||= RubyProvisioningApi::Connection.new
    end

  end
end