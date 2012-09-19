module RubyProvisioningApi
  class Connection

    attr_reader :token

    def initialize
      client = client('https://www.google.com')
      response = client.post '/accounts/ClientLogin', {:Email => "#{RubyProvisioningApi.configuration[:username]}@#{RubyProvisioningApi.configuration[:domain]}", :Passwd => RubyProvisioningApi.configuration[:password], :accountType =>  "HOSTED", :service => "apps"}
      # Set the token
      @token = response.body.split("\n").last.split('Auth=').last
    end

    def client(url)
      # TODO: move ca_file option into initializer
      client = Faraday.new(:url => url, :ssl => {:ca_file => '/usr/lib/ssl/certs/ca-certificates.crt'}) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        # TODO :move log level into initializer
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

  end
end