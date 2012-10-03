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
    # It's possible to write an initializer to customize the behaviour of the gem. For a list of all the available
    # options see the {Configuration} class
    #
    # @example Ruby on rials initializer for the Ruby Provisioning Api gem
    #   RubyProvisioningApi.configure do |config|
    #     config.config_file = "/path/to/file.yml"
    #     config.ca_file = "/path/to/ca_file"
    #   end
    #
    # @yield [configuration] current configuration
    # @yieldparam configuration [Configuration] current gem configuration
    #
    def configure
      yield(configuration)
    end

    # Returns the connection to the google provisioning api web service.
    #
    # If the connection exists, returns the existing one, otherwise creates a new connection through the {Connection}
    # class.
    #
    # @example Get the connection to google provisioning api
    #   RubyProvisioningApi.connection # => [Connection]
    #
    # @return [Connection]
    #
    def connection
      @connection ||= RubyProvisioningApi::Connection.new
    end

  end
end