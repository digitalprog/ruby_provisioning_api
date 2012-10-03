module RubyProvisioningApi

  # The Connection class gives the gem the ability to connect to google provisioning api.
  # It manages the authentication and all the connections with the google web service.
  #
  # @attr [String] token Authentication token generated by google api web service
  #
  class Connection

    attr_reader :token

    def initialize
      client = client('https://www.google.com')
      response = client.post '/accounts/ClientLogin', {:Email => "#{RubyProvisioningApi.configuration.config[:username]}@#{RubyProvisioningApi.configuration.config[:domain]}", :Passwd => RubyProvisioningApi.configuration.config[:password], :accountType =>  "HOSTED", :service => "apps"}
      # Set the token
      @token = response.body.split("\n").last.split('Auth=').last
    end

    def client(url)
      client_params = { :url => url }
      if RubyProvisioningApi.configuration.ca_file
        client_params[:ssl] = {:ca_path => RubyProvisioningApi.configuration.ca_file}
      end
      client = Faraday.new(client_params) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger if RubyProvisioningApi.configuration.http_debug # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

  end
end