module RubyProvisioningApi
  class Entity

    BASE_ENTITY_URL = 'https://apps-apis.google.com'
    BASE_PATH = '/a/feeds'

    def self.perform(action, params = nil)
      connection = RubyProvisioningApi.connection
      client = connection.client(BASE_ENTITY_URL)
      method = action[:method]
      url = action[:url]

      response = client.send(action[:method].downcase) do |req|
        req.url "#{BASE_ENTITY_URL}#{BASE_PATH}#{action[:url]}"
        req.headers['Content-Type'] = 'application/atom+xml'
        req.headers['Authorization'] = "GoogleLogin auth=#{connection.token}"
        req.body = params if params
      end
    end

    # private
    def self.response_error?(response)
      (400..600).include?(response.status)
    end

    def self.check_response(response)
      if (400..600).include?(response.status)
        xml = Nokogiri::XML(response.body)
        error_code = xml.xpath('//error').first.attributes["errorCode"].value
        error_description = xml.xpath('//error').first.attributes["reason"].value
        RubyProvisioningApi.const_set(error_description, Class.new(RubyProvisioningApi::Error)) unless RubyProvisioningApi.const_defined? error_description
        raise "RubyProvisioningApi::#{error_description}".constantize
      end
      true
    end

  end
end