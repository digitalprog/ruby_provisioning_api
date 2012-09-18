module RubyProvisioningApi

  class Configuration

    attr_accessor :config_file

    def initialize
    		# For rails env
      # @ldap_config_file = "#{Rails.root}/config/google_apps.yml"
      # Temporary patch. Insert your config file here.
      @config_file = "YOUR_PERSONAL_DIRECTORY/google_apps.yml"

    end

  end
end