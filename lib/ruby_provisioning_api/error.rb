module RubyProvisioningApi

  # A general RubyProvisioningApi exception
  # All RubyProvisioningApi exceptions are descendants of the error class.
  #
  # *NOTE:* Exceptions raised by google provisioning api protocol in Entity::check_response are generated on the fly and
  # are also descendants of the Error class.
  #
  class Error < StandardError

    # @param [String] message the message of the exception
    #
    def initialize(message = nil)
      @message = message || self.class.to_s.split("::").last.underscore.humanize
    end

    # Overrides Exception#to_s method to output a custom message
    #
    def to_s
      @message
    end

  end

  # Raised when the configuration file (yml) can not be found in the specified path.
  #
  # @attr [String] filename The name or the full path of the file that couldn't be found
  #
  class ConfigurationFileMissing < Error

    # ConfigurationFileMissing initializer
    #
    # @param [String] filename The name or the full path of the file that couldn't be found
    #
    def initialize(filename)
      super("RubyProvisioningApi: Configuration file #{filename} not found. Did you forget to define it?")
    end

  end

  # Raised when the configuration file is not valid (i.e.: missing configuration parameters).
  #
  class ConfigurationError < Error

    def initialize
      super("RubyProvisioningApi: Configuration file not valid.")
    end

  end
end