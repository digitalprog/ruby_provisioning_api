module RubyProvisioningApi

  class Error < StandardError

    def initialize
      @message = self.class.to_s.split("::").last.underscore.humanize
    end

    def to_s
      @message
    end

  end

  class InvalidArgument < Error

    def initialize
      @message = "Wrong number of arguments specified."
    end

    def to_s
      @message
    end

  end

end