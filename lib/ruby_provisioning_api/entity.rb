module RubyProvisioningApi
  class Entity

    BASE_ENTITY_URL = 'https://apps-apis.google.com'
    BASE_PATH = '/a/feeds'

    def self.perform(action,params = nil)
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
  end
end