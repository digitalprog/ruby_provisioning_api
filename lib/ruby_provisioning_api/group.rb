module RubyProvisioningApi

  class Group 
    extend Entity
    include Member

    include ActiveModel::Validations
    include ActiveModel::Dirty

    attr_accessor :group_id, :group_name, :description, :email_permission
    attr_reader :GROUP_PATH

    GROUP_PATH = "/group/2.0/#{RubyProvisioningApi.configuration[:domain]}"
    GROUP_ATTRIBUTES = ['groupId','groupName','description','emailPermission']

    ACTIONS = { 
      :create =>  { method: "POST" , url: "#{GROUP_PATH}"},
      :update =>  { method: "PUT" , url: "#{GROUP_PATH}/groupId"},
      :delete =>  { method: "DELETE" , url: "#{GROUP_PATH}/groupId"},
      :retrieve_all => { method: "GET" , url: "#{GROUP_PATH}" },
      :retrieve_groups => { method: "GET" , url: "#{GROUP_PATH}/?member=memberId" },
      :retrieve => { method: "GET" , url: "#{GROUP_PATH}/groupId" },
      :add_member => { method: "POST" , url: "#{GROUP_PATH}/groupId/member" },
      :delete_member => { method: "DELETE" , url: "#{GROUP_PATH}/groupId/member/memberId" },
      :has_member => {method: "GET", url: "#{GROUP_PATH}/groupId/member/memberId"}
    }
    
    # @param [Hash] attributes the options to create a Group with.
    # @option attributes [String] :group_id group identification
    # @option attributes [String] :group_name name of the group
    # @option attributes [String] :description description of the group
    # @option attributes [String] :email_permission Owner or Member    
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    # Retrieve all groups in the domain  
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_groups_in_a_domain GET https://apps-apis.google.com/a/feeds/group/2.0/domain[?[start=]]
    # @return [Array<Group>] all groups in the domain 
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

    # Save a group 
    # @see https://developers.google.com/google-apps/provisioning/#creating_a_group POST https://apps-apis.google.com/a/feeds/group/2.0/domain
    # @return [Boolean] true of false depending the status of the operation
    def save
      return false unless valid?
      # If group is present, this is an update
      update = Group.present?(group_id)
      # Creating the XML request
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.send(:'atom:entry', 'xmlns:atom' => 'http://www.w3.org/2005/Atom', 'xmlns:apps' => 'http://schemas.google.com/apps/2006') {
          xml.send(:'atom:category', 'scheme' => 'http://schemas.google.com/g/2005#kind', 'term' => 'http://schemas.google.com/apps/2006#emailList')
          xml.send(:'apps:property', 'name' => 'groupId', 'value' => group_id) if update
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

    # Initialize and save a group 
    # @see https://developers.google.com/google-apps/provisioning/#creating_a_group POST https://apps-apis.google.com/a/feeds/group/2.0/domain
    # @return [Boolean] true of false depending the status of the operation
    # @param [Hash] params the options to create a Group with.
    # @option params [String] :group_id group identification
    # @option params [String] :group_name name of the group
    # @option params [String] :description description of the group
    # @option params [String] :email_permission Owner or Member    
    def self.create(params = {})
      group = Group.new(params).save    
    end

    # Retrieve a group
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_a_group GET https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId    
    # @return [Group] Group object
    # @param [String] group_id group identification
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

    # Update attributes of a group 
    # @see https://developers.google.com/google-apps/provisioning/#updating_a_group PUT https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId  
    # @return [Boolean] true of false depending the status of the operation
    # @param [Hash] params the options to create a Group with.
    # @option params [String] :group_name name of the group
    # @option params [String] :description description of the group
    # @option params [String] :email_permission Owner or Member   
    def update_attributes(params = {})
      self.group_name = params[:group_name] if params[:group_name]
      self.description = params[:description] if params[:description]
      self.email_permission = params[:email_permission] if params[:email_permission]
      update
    end

    # Update group 
    # @see https://developers.google.com/google-apps/provisioning/#updating_a_group PUT https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId  
    # @return [Boolean] true of false depending the status of the operation
    def update
      save 
    end

    # Delete group 
    # @see https://developers.google.com/google-apps/provisioning/#deleting_a_member_from_an_group DELETE https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId 
    # @return [Boolean] true of false depending the status of the operation
    def delete
      # Creating a deep copy of ACTION object
      params = Marshal.load(Marshal.dump(ACTIONS[:delete]))
      # Replacing placeholder groupId with correct group_id
      params[:url].gsub!("groupId",group_id)
      # Perform the request & Check if the response contains an error
      Entity.check_response(Entity.perform(params))
    end

    # Retrieve all groups for a given member
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_groups_for_a_member GET https://apps-apis.google.com/a/feeds/group/2.0/domain/?member=memberId[&directOnly=true|false]  
    # @return [Array<Group>] all groups for a given member
    # @param [String] member_id member identification
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

    # Add member to group
    # @see https://developers.google.com/google-apps/provisioning/#adding_a_member_to_a_group POST https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member  
    # @return [Boolean] true of false depending the status of the operation
    # @param [String] member_id member identification
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

    # Group membership of a given member
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_members_of_a_group GET https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member/memberId
    # @return [Boolean] true if user is a member of group
    # @param [String] member_id member identification
    def has_member?(member_id)
      # Creating a deep copy of ACTION object
      params = Marshal.load(Marshal.dump(ACTIONS[:has_member]))
      # Replacing placeholder groupId with correct group_id
      params[:url].gsub!("groupId",group_id)
      # Replacing placeholder groupId with correct group_id
      params[:url].gsub!("memberId",member_id)
      # Perform the request & Check if the response contains an error
      self.class.check_response(self.class.perform(params))   
    end

    # Delete group membership of a given member
    # @see https://developers.google.com/google-apps/provisioning/#deleting_member_from_an_group DELETE https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member/memberId
    # @return [Boolean] true of false depending the status of the operation
    # @param [String] member_id member identification
    def delete_member(member_id)
      member = Member.find(member_id)
      # Creating a deep copy of ACTION object
      params = Marshal.load(Marshal.dump(ACTIONS[:delete_member]))
      # Replacing placeholder groupId with correct group_id
      params[:url].gsub!("groupId",group_id)
      # Replacing placeholder memberId with correct member_id
      params[:url].gsub!("memberId",member_id)
      # Perform the request & Check if the response contains an error
      Entity.check_response(Entity.perform(params)) 
    end

    # Retrieve member for a group GET https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member/memberId
    # def member(member_id)
    # end
    
    # def add_owner(owner_id)
    # end

    # def owners
    # end

    # def owner?
    # end

    # def delete_owner(owner_id)
    # end

  end
end	



