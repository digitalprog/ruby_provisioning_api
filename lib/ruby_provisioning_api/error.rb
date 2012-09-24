module RubyProvisioningApi

  # A general RubyProvisioningApi exception
  # All RubyProvisioningApi exceptions are descendants of the error class.
  #
  # *NOTE:* Exceptions raised by google provisioning api protocol in Entity::check_response are generated on the fly and
  # are also descendants of the Error class.
  #
  #
  #
  class Error < StandardError

    # @param [String] message the message of the exception
    def initialize(message = nil)
      @message = message || self.class.to_s.split("::").last.underscore.humanize
    end

    def to_s
      @message
    end

  end

end