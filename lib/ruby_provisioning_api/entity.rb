module RubyProvisioningApi

  # This module defines the entity methods. It is extended by User and Group classes.
  #
  # In this module are defined the common operations required by either the Group and User classes.
  # We extracted this code from these two classes to avoid code duplication.
  #
  module Entity

    # Performs an http action to google api web services
    #
    # @param [Hash] action
    # @param [String] params Body of the http request (defaults to nil)
    # @option action [String] :method The http verb to use for the request [GET, POST, PUT, DELETE]
    # @option action [String] :url The url to use
    #
    # @return [Faraday::Response] The response from google apps web services
    #
    def perform(action, params = nil)
      connection = RubyProvisioningApi.connection
      client = connection.client(RubyProvisioningApi.configuration.base_apps_url)

      client.send(action[:method].downcase) do |req|
        req.url "#{RubyProvisioningApi.configuration.base_apps_url}#{RubyProvisioningApi.configuration.base_path}#{action[:url]}"
        req.headers['Content-Type'] = 'application/atom+xml'
        req.headers['Authorization'] = "GoogleLogin auth=#{connection.token}"
        req.body = params if params
      end
    end

    # Checks if the response code is an HTTP error code
    #
    # @param [Faraday::Response] response The full HTTP response
    # @return [Boolean] false if no error occurred, true otherwise
    #
    def response_error?(response)
      (400..600).include?(response.status)
    end

    def check_response(response)
      if (400..600).include?(response.status)
        xml = Nokogiri::XML(response.body)
        error_description = xml.xpath('//error').first.attributes["reason"].value
        RubyProvisioningApi.const_set(error_description, Class.new(RubyProvisioningApi::Error)) unless RubyProvisioningApi.const_defined? error_description
        raise "RubyProvisioningApi::#{error_description}".constantize
      end
      true
    end

    def present?(id)
      begin
        self.find(id)
        true
      rescue
        false
      end
    end

    def prepare_params_for(action, options = {})
      options.stringify_keys!
      params = deep_copy(RubyProvisioningApi.configuration.send("#{self.name.demodulize.underscore}_actions")[action])
      options.each_pair do |k, v|
        params[:url].gsub!(k, v)
      end
      params
    end

    def deep_copy(element)
      Marshal.load(Marshal.dump(element))
    end

  end

end