module RubyProvisioningApi
  class Group < Entity

    attr_accessor :group_id, :group_name, :description, :email_permission
    attr_reader :GROUP_PATH

    GROUP_PATH = "/group/2.0/#{RubyProvisioningApi.configuration[:domain]}"

    ACTIONS = { 
      :create =>  { method: "POST" , url: "#{GROUP_PATH}"},
      :update =>  { method: "PUT" , url: "#{GROUP_PATH}/groupId"},
      :delete =>  { method: "DELETE" , url: "#{GROUP_PATH}/groupId"},
      :retrieve_all => { method: "GET" , url: "#{GROUP_PATH}" },
      :retrieve_groups => { method: "GET" , url: "#{GROUP_PATH}/?member=memberId" },
      :retrieve => { method: "GET" , url: "#{GROUP_PATH}/groupId" }
    }

    HTTP_OK_STATUS = [200,201]
      
  	def initialize(group_id, group_name, description, email_permission)
      self.group_id = group_id
      self.group_name = group_name
      self.description = description
      self.email_permission = email_permission
  	end

    def initialize
    end

    # Retrieve all groups in a domain  GET https://apps-apis.google.com/a/feeds/group/2.0/domain[?[start=]]
    def self.all
      response = perform(ACTIONS[:retrieve_all])
      case response.status
        when 200
          # Parse the response
          xml = Nokogiri::XML(response.body)
          groups = []
          xml.children.css("entry").each do |entry|
            group = Group.new

            for attribute_name in ['groupId','groupName','description','emailPermission']
            group.send("#{attribute_name.underscore}=", entry.css("apps|property[name='#{attribute_name}']").attribute("value").value)
            end
            groups << group
          end
          groups
        when 400
          # Gapps error?
          xml = Nokogiri::XML(response.body)
          error_code = xml.xpath('//error').first.attributes["errorCode"].value
          error_description = xml.xpath('//error').first.attributes["reason"].value
          puts "Google provisioning Api error #{error_code}: #{error_description}"
      end
    end

   # Save(Create) a group POST https://apps-apis.google.com/a/feeds/group/2.0/domain
    def save
      Group.create(group_id, group_name, description, email_permission)
    end

    # Create a group POST https://apps-apis.google.com/a/feeds/group/2.0/domain
    def self.create(group_id, group_name, description, email_permission)
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.send(:'atom:entry', 'xmlns:atom' => 'http://www.w3.org/2005/Atom', 'xmlns:apps' => 'http://schemas.google.com/apps/2006') {
          xml.send(:'atom:category', 'scheme' => 'http://schemas.google.com/g/2005#kind', 'term' => 'http://schemas.google.com/apps/2006#emailList')
          xml.send(:'apps:property', 'name' => 'groupId', 'value' => group_id)
          xml.send(:'apps:property', 'name' => 'groupName', 'value' => group_name)
          xml.send(:'apps:property', 'name' => 'description', 'value' => description)
          xml.send(:'apps:property', 'name' => 'emailPermission', 'value' => email_permission)
        }
      end
      HTTP_OK_STATUS.include?(perform(ACTIONS[:create],builder.to_xml).status)    
    end

    # Retrieve a group GET https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId
    def self.find(group_id)
      # Creating a deep copy of ACTION object
      params = Marshal.load(Marshal.dump(ACTIONS[:retrieve]))
      # Replacing place holder groupId with correct group_id
      params[:url].gsub!("groupId",group_id)
      response = perform(params)
      # Check if the response contains an error
      check_response(response)
      # Parse the response
      xml = Nokogiri::XML(response.body)
      group = Group.new
      for attribute_name in ['groupId','groupName','description','emailPermission']
        group.send("#{attribute_name.underscore}=",xml.children.css("entry apps|property[name='#{attribute_name}']").attribute("value").value)
      end
      group
    end

    #update attributes

    # Update group information   PUT https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId
    def update
      # Creating a deep copy of ACTION object
      params = Marshal.load(Marshal.dump(ACTIONS[:update]))
      # Replacing place holder groupId with correct group_id
      params[:url].gsub!("groupId",group_id)

      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.send(:'atom:entry', 'xmlns:atom' => 'http://www.w3.org/2005/Atom', 'xmlns:apps' => 'http://schemas.google.com/apps/2006') {
          xml.send(:'atom:category', 'scheme' => 'http://schemas.google.com/g/2005#kind', 'term' => 'http://schemas.google.com/apps/2006#emailList')
          xml.send(:'apps:property', 'name' => 'groupName', 'value' => group_name)
          xml.send(:'apps:property', 'name' => 'description', 'value' => description)
          xml.send(:'apps:property', 'name' => 'emailPermission', 'value' => email_permission)
        }
      end 
      HTTP_OK_STATUS.include?(Entity.perform(params,builder.to_xml).status)     
    end

    # Delete group  DELETE https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId
    def self.delete(group_id)
      # Creating a deep copy of ACTION object
      params = Marshal.load(Marshal.dump(ACTIONS[:delete]))
      # Replacing place holder groupId with correct group_id
      params[:url].gsub!("groupId",group_id)
      HTTP_OK_STATUS.include?(perform(params).status) 
    end

    # Retrieve all groups for a member GET https://apps-apis.google.com/a/feeds/group/2.0/domain/?member=memberId[&directOnly=true|false]
    def self.groups(member_id)
      # Creating a deep copy of ACTION object
      params = Marshal.load(Marshal.dump(ACTIONS[:retrieve_groups]))
      # Replacing place holder groupId with correct group_id
      params[:url].gsub!("memberId",member_id)
      response = perform(params)
      case response.status
        when 200
          # Parse the response
          xml = Nokogiri::XML(response.body)
          groups = []
          xml.children.css("entry").each do |entry|
            group = Group.new

            for attribute_name in ['groupId','groupName','description','emailPermission']
            group.send("#{attribute_name.underscore}=", entry.css("apps|property[name='#{attribute_name}']").attribute("value").value)
            end
            groups << group
          end
          groups
        when 400
          # Gapps error?
          xml = Nokogiri::XML(response.body)
          error_code = xml.xpath('//error').first.attributes["errorCode"].value
          error_description = xml.xpath('//error').first.attributes["reason"].value
          puts "Google provisioning Api error #{error_code}: #{error_description}"
      end      
    end

  end
end	



