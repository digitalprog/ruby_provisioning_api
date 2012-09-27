module RubyProvisioningApi
  class << self

    attr_writer :configuration
    attr_reader :connection

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