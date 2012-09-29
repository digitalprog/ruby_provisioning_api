module RubyProvisioningApi
  class << self

    attr_writer :configuration
    attr_reader :connection

    # Adds configuration ability to the gem
    def configuration
      @configuration ||= RubyProvisioningApi::Configuration.new
    end

    def configure
      yield(configuration)
      @configuration = RubyProvisioningApi::Configuration.new(configuration.config_file)
    end

    def connection
      @connection ||= RubyProvisioningApi::Connection.new
    end

  end
end