module RubyProvisioningApi

  class Configuration

    attr_accessor :config_file, :config

    def initialize
    		# For rails env
      # @ldap_config_file = "#{Rails.root}/config/google_apps.yml"
      # Temporary patch. Insert your config directory here.
      config_file = "{YOUR_DIRECTORY}/ruby_provisioning_api/lib/ruby_provisioning_api/config/google_apps.yml"
      # Get necessary data from configuration files
      if File.exist?(config_file)
        @config = YAML.load_file(config_file)
      else
        raise "RubyProvisioningApi: File #{config_file} not found, maybe you forgot to define it ?"
      end
    end

  end
end