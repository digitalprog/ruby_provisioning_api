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
      :retrieve => { method: "GET" , url: "#{GROUP_PATH}/groupId" },
      :add_member => { method: "POST" , url: "#{GROUP_PATH}/groupId/member" }
    }
    
    GROUP_ATTRIBUTES = ['groupId','groupName','description','emailPermission']


    # Group initialization
    # Params:
    # groupId, groupName, description, emailPermission
    def initialize(params = nil)
      if params.nil? || (params.has_key?(:group_id) && params.has_key?(:group_name) && params.has_key?(:description) && params.has_key?(:email_permission))
        if params
          self.group_id = params[:group_id] 
          self.group_name = params[:group_name] 
          self.description = params[:description] 
          self.email_permission = params[:email_permission]
        end
      else
        raise InvalidArgument
      end
    end

    # Retrieve all groups in a domain  GET https://apps-apis.google.com/a/feeds/group/2.0/domain[?[start=]]
    def self.all
      # Perform the request & Check if the response contains an error
      check_response(perform(ACTIONS[:retrieve_all]))       
      # Parse the response
      xml = Nokogiri::XML(perform(ACTIONS[:retrieve_all]).body)
      # Prepare a Groups array
      groups = []
      xml.children.css("entry").each do |entry|
        group = Group.new
        GROUP_ATTRIBUTES.each do |attribute_name|
          group.send("#{attribute_name.underscore}=", entry.css("apps|property[name='#{attribute_name}']").attribute("value").value)
        end
        # Fill groups array        
        groups << group
      end
      # Return the array of Groups
      groups
    end


   # Save(Create) a group POST https://apps-apis.google.com/a/feeds/group/2.0/domain
    def save
      update = false
      begin
        Group.find(group_id)
        update = true
      rescue Exception => e
      end
      # Creating the XML request
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.send(:'atom:entry', 'xmlns:atom' => 'http://www.w3.org/2005/Atom', 'xmlns:apps' => 'http://schemas.google.com/apps/2006') {
          xml.send(:'atom:category', 'scheme' => 'http://schemas.google.com/g/2005#kind', 'term' => 'http://schemas.google.com/apps/2006#emailList')
          xml.send(:'apps:property', 'name' => 'groupId', 'value' => group_id) if !update
          xml.send(:'apps:property', 'name' => 'groupName', 'value' => group_name)
          xml.send(:'apps:property', 'name' => 'description', 'value' => description)
          xml.send(:'apps:property', 'name' => 'emailPermission', 'value' => email_permission)
        }
      end
      if !update
        #Acting on a new object
        # Check if the response contains an error
        Entity.check_response(Entity.perform(ACTIONS[:create],builder.to_xml)) 
      else
        #Acting on an existing object
        # Creating a deep copy of ACTION object
        params = Marshal.load(Marshal.dump(ACTIONS[:update]))
        # Replacing placeholder groupId with correct group_id
        params[:url].gsub!("groupId",group_id)
        # Perform the request & Check if the response contains an error
        Entity.check_response(Entity.perform(params,builder.to_xml))  
      end
    end

    # Create a group POST https://apps-apis.google.com/a/feeds/group/2.0/domain
    # Group initialization
    # Params:
    # groupId, groupName, description, emailPermission
    def self.create(params = {})
      if params.has_key?(:group_id) && params.has_key?(:group_name) && params.has_key?(:description) && params.has_key?(:email_permission)
        # Set attributes
        group = Group.new(:group_id => params[:group_id], :group_name => params[:group_name], :description => params[:description], :email_permission => params[:email_permission])
        # Save group
        group.save
      else
        raise InvalidArgument
      end       
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

    # Update group information   PUT https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId
    def update_attributes(params)
      self.group_name = params[:group_name] if params[:group_name]
      self.description = params[:description] if params[:description]
      self.email_permission = params[:email_permission] if params[:email_permission]
      update
    end

    def update
      save 
    end

    # Delete group  DELETE https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId
    def delete
      # Creating a deep copy of ACTION object
      params = Marshal.load(Marshal.dump(ACTIONS[:delete]))
      # Replacing placeholder groupId with correct group_id
      params[:url].gsub!("groupId",group_id)
      # Perform the request & Check if the response contains an error
      Entity.check_response(Entity.perform(params))
    end

    # Retrieve all groups for a member GET https://apps-apis.google.com/a/feeds/group/2.0/domain/?member=memberId[&directOnly=true|false]
    def self.groups(member_id)
      # Creating a deep copy of ACTION object
      params = Marshal.load(Marshal.dump(ACTIONS[:retrieve_groups]))
      # Replacing place holder groupId with correct group_id
      params[:url].gsub!("memberId",member_id)
      response = perform(params)
      # Perform the request & Check if the response contains an error
      check_response(response)     
      # Parse the response
      xml = Nokogiri::XML(response.body)
      # Prepare a Groups array
      groups = []
      xml.children.css("entry").each do |entry|
        # Prepare a Group object
        group = Group.new
        GROUP_ATTRIBUTES.each do |attribute_name|
          # Set group attributes
          group.send("#{attribute_name.underscore}=", entry.css("apps|property[name='#{attribute_name}']").attribute("value").value)
        end
        # Fill groups array
        groups << group
      end
      # Return the array of Groups
      groups
    end

    # Adding a Member to a Group POST https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member
    def add_member(member_id)
      user = User.find(member_id)
      # Creating the XML request
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.send(:'atom:entry', 'xmlns:atom' => 'http://www.w3.org/2005/Atom', 'xmlns:apps' => 'http://schemas.google.com/apps/2006') {
          xml.send(:'atom:category', 'scheme' => 'http://schemas.google.com/g/2005#kind', 'term' => 'http://schemas.google.com/apps/2006#emailList')
          xml.send(:'apps:property', 'name' => 'memberId', 'value' => member_id) 
        }
      end
      # Creating a deep copy of ACTION object
      params = Marshal.load(Marshal.dump(ACTIONS[:add_member]))
      # Replacing placeholder groupId with correct group_id
      params[:url].gsub!("groupId",group_id)
      # Perform the request & Check if the response contains an error
      Entity.check_response(Entity.perform(params,builder.to_xml))  
    end

    # Retrieving all members for a group GET https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member[?[start=]&[includeSuspendedUsers=true|false]]
    def members
      User.users(group_id)
    end
    # Retrieve member for a group GET https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member/memberId
    def member(member_id)
    end

    # Deleting a member from a group DELETE https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member/memberId
    def delete_member(member_id)
    end

    def add_owner(owner_id)
    end

    def owners
    end

    def owner?
    end

    def member?
    end

    def delete_owner(owner_id)
    end

  end
end	



