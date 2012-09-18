module RubyProvisioningApi
  class Connection

    attr_reader :token

    def initialize
      # Get necessary data from configuration files
      if File.exist?(RubyProvisioningApi.configuration.config_file)
        @GAPPS = YAML.load_file(RubyProvisioningApi.configuration.config_file)
      else
        raise "RubyProvisioningApi: File #{RubyProvisioningApi.configuration.config_file} not found, maybe you forgot to define it ?"
      end

      client = client('https://www.google.com')

      response = client.post '/accounts/ClientLogin', {:Email => @GAPPS[:email], :Passwd => @GAPPS[:password], :accountType =>  "HOSTED", :service => "apps"}
      # Set the token
      @token = response.body.split("\n").last.split('Auth=').last
    end

    def client(url)
      client = Faraday.new(:url => url) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

  end
end