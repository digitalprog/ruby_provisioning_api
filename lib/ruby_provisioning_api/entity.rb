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


# The groupId (required, group_id in Python) argument identifies the ID of the new group.
# The groupName (required, group_name in Python) (required) argument identifies the name of the group being added.
# The description argument provides a general description of the group.
# The emailPermission argument sets the permissions level of the group.






# string = 

# response = client.post do |req|
#   req.url 'https://apps-apis.google.com/a/feeds/group/2.0/damianobraga.com'
#   req.headers['Content-Type'] = 'application/atom+xml'
#   req.headers['Authorization'] = "GoogleLogin auth=#{connection.token}"
#   req.body = string
# end

# # adds <apps:property> element in the message body.
# def about_group(group_id, properties)
#   self.elements["atom:entry/atom:category"].add_attribute("term", "http://schemas.google.com/apps/2006#emailList")
#   self.elements["atom:entry"].add_element "apps:property", {"name" => "groupId", "value" => group_id } 
#   self.elements["atom:entry"].add_element "apps:property", {"name" => "groupName", "value" => properties[0] } 
#   self.elements["atom:entry"].add_element "apps:property", {"name" => "description", "value" => properties[1] } 
#   self.elements["atom:entry"].add_element "apps:property", {"name" => "emailPermission", "value" => properties[2] } 
# end

