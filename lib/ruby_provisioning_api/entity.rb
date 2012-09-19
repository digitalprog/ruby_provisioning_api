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
        req.body = '{"groupId": "Unagi","groupName": "name","description": "desc","emailPermission": "Owner"}' if params
      end
    end
  end
end


# The groupId (required, group_id in Python) argument identifies the ID of the new group.
# The groupName (required, group_name in Python) (required) argument identifies the name of the group being added.
# The description argument provides a general description of the group.
# The emailPermission argument sets the permissions level of the group.


# builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|

builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
  xml.send(:'atom:entry') { 
    xml['xmlns'].atom => 'http://www.w3.org/2005/Atom'
  }
end


# string = <<-EOS
# <?xml version="1.0" encoding="UTF-8"?>
# <atom:entry
# xmlns:atom="http://www.w3.org/2005/Atom"
# xmlns:apps="http://schemas.google.com/apps/2006">
# <atom:category
# scheme="http://schemas.google.com/g/2005#kind"
# term="http://schemas.google.com/apps/2006#emailList"/>
# <apps:property name="groupId" value="testabc"/>
# <apps:property name="groupName" value="test name"/>
# <apps:property name="description" value="desc"/>
# <apps:property name="emailPermission" value="Owner"/>
# </atom:entry>
# EOS

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

