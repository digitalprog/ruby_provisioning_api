module RubyProvisioningApi

  class Error < StandardError
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