require "ruby_provisioning_api/version"
require "ruby_provisioning_api/connection"
require "faraday"

module RubyProvisioningApi
  class << self

    def new
      RubyProvisioningApi::Connection.new()
    end
  end
end
