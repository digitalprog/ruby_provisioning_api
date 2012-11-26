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

    # Checks the response from google web services
    #
    # @param [Faraday::Response] response The response returned by google web services
    # @return [Boolean] true if no error occurred
    # @raise [RubyProvisioningApi::Error] if there was an error
    #
    def check_response(response)
      if response_error? response
        xml = Nokogiri::XML(response.body)
        error_description = xml.xpath('//error').first.attributes["reason"].value
        RubyProvisioningApi.const_set(error_description, Class.new(RubyProvisioningApi::Error)) unless RubyProvisioningApi.const_defined? error_description
        raise "RubyProvisioningApi::#{error_description}".constantize
      end
      true
    end

    # Checks if the response code is an HTTP error code
    #
    # @param [Faraday::Response] response The full HTTP response
    # @return [Boolean] false if no error occurred, true otherwise
    #
    def response_error?(response)
      (400..600).include?(response.status)
    end

    # Checks if an entity (User or Group) exists
    #
    # @param [String] id The id of the entity to check the existence of
    # @return [Boolean] true if the entity exists, false otherwise
    #
    def present?(id)
      begin
        self.find(id)
        true
      rescue
        false
      end
    end

    # Prepares the parameters for a request to the google provisioning api web service.<br/>
    # This method takes two arguments:<br/>
    # - the first argument identifies the action name for the entity (User or Group)
    # - the second parameter is a Hash with the substitution to apply to the default request url
    #
    # @example Preparing parameters to find the user "foo"
    #   user_name = "foo"
    #   params = prepare_params_for(:retrieve, "userName" => user_name) # => [Hash]
    #
    # @param [Symbol] action The action to prepare params for
    # @param [Hash] options The substitution to the default url (i.e.: "userName" => user_name)
    # @return [Hash] The params for the requested operation with the requested substitutions
    #
    def prepare_params_for(action, options = {})
      options.stringify_keys!
      params = deep_copy(RubyProvisioningApi.configuration.send("#{self.name.demodulize.underscore}_actions")[action])
      options.each_pair do |k, v|
        params[:url].gsub!(k, v)
      end
      params
    end

    # Deep copy an object
    #
    # @param [Object] element The object to copy
    # @return [Object]
    #
    def deep_copy(element)
      Marshal.load(Marshal.dump(element))
    end

    def next_page(xml)
      unless xml.css("link[rel=next]").empty?
        xml.css("link[rel=next]").attribute("href")
      else
        false
      end
    end

    private

    def perform_and_check_response(params)
      response = perform(params)
      check_response(response)
      Nokogiri::XML(response.body)
    end

  end

end