module RubyProvisioningApi

  # @attr [String] group_id Group identification
  # @attr [String] group_name Group name
  # @attr [String] description Group description
  # @attr [String] email_permission Group permission: Owner or Member 
  #
  class Group 
    extend Entity
    include Member
    include Owner

    include ActiveModel::Validations
    include ActiveModel::Dirty

    attr_accessor :group_id, :group_name, :description, :email_permission

    # Group attributes list.
    # This constant is used to dynamically extract group's attributes from the google API response.
    #
    GROUP_ATTRIBUTES = ['groupId','groupName','description','emailPermission']
    
    # @param [Hash] params the options to create a Group with.
    # @option params [String] :group_id Group identification
    # @option params [String] :group_name Group name
    # @option params [String] :description Group description
    # @option params [String] :email_permission Group permission: Owner or Member
    #
    def initialize(params = {})
      params.each do |name, value|
        send("#{name}=", value)
      end
    end

    # Retrieve all groups in the domain 
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain[?[start=]]</i>
    #
    # @example Retrieve all group in the current domain
    #   RubyProvisioningApi::Group.all # => [Array<Group>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_groups_in_a_domain
    # @return [Array<Group>] all groups in the domain
    #
    def self.all
      response = perform(RubyProvisioningApi.configuration.group_actions[:retrieve_all])
      # Perform the request & Check if the response contains an error
      check_response(response)       
      # Parse the response
      xml = Nokogiri::XML(response.body)
      # Return the array of Groups
      groups = parse_group_response(xml)
    end

    # Retrieve a group
    # @param [String] group_id Group identification
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId </i>
    #
    # @example Find the group "foo"
    #   group = RubyProvisioningApi::Group.find("foo") # => [Group]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_a_group
    # @return [Group] the group found
    # @raise [Error] if group does not exist
    #      
    def self.find(group_id)
      params = prepare_params_for(:retrieve, "groupId" => group_id)
      response = perform(params)
      # Check if the response contains an error
      check_response(response)
      # Parse the response
      xml = Nokogiri::XML(response.body)
      group = Group.new
      GROUP_ATTRIBUTES.each do |attribute_name|
        group.send("#{attribute_name.underscore}=",xml.children.css("entry apps|property[name='#{attribute_name}']").attribute("value").value)
      end
      group
    end

    # Initialize and save a group 
    # @param [Hash] params the options to create a Group with.
    # @option params [String] :group_id Group identification
    # @option params [String] :group_name Group name
    # @option params [String] :description Group description 
    # @option params [String] :email_permission Group permission: Owner or Member 
    # @note This method executes a <b>POST</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain</i>
    #
    # @example Create the group "foo"
    #   group = RubyProvisioningApi::Group.create(:group_id => "foo",
    #                                             :group_name => "foo name" ,
    #                                             :description => "bar",
    #                                             :email_permission => "Owner") # => true
    #
    # @see https://developers.google.com/google-apps/provisioning/#creating_a_group
    # @return [Boolean] true if created, false if not valid or not created
    # @raise [Error] if group already exists (group_id must be unique)
    #    
    def self.create(params = {})
      group = Group.new(params).save    
    end

    # Save a group
    # @note This method executes a <b>POST</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain</i>
    #
    # @example Save the group "foo"
    #   group = RubyProvisioningApi::Group.new( :group_id => "foo", :group_name => "foo name" , :description => "bar", :email_permission => "Owner" ).save # => true
    #
    # @see https://developers.google.com/google-apps/provisioning/#creating_a_group
    # @return [Boolean] true if saved, false if not valid or not saved
    # @raise [Error] if group already exists (group_id must be unique)
    #
    def save
      return false unless valid?
      # If group is present, this is an update
      update = Group.present?(group_id)
      # Creating the XML request
      builder = prepare_xml_request(:group_id => group_id , :group_name => group_name, :description => description, :email_permission => email_permission, :update => update)
      if !update
        #Acting on a new object
        # Check if the response contains an error
        self.class.check_response(self.class.perform(RubyProvisioningApi.configuration.group_actions[:create],builder.to_xml))
      else
        #Acting on an existing object
        params = self.class.prepare_params_for(:update, "groupId" => group_id)
        # Perform the request & Check if the response contains an error
        self.class.check_response(self.class.perform(params,builder.to_xml))  
      end
    end

    # Update a group
    # @note This method executes a <b>PUT</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId</i>
    #
    # @example Update the group "test" description from "foo" to "bar"
    #   group = RubyProvisioningApi::Group.find("test") # => true
    #   group.description # => "foo"
    #   group.description = "bar" # => "bar"
    #   group.update # => true
    #
    # @see https://developers.google.com/google-apps/provisioning/#updating_a_group
    # @return [Boolean] true if updated, false otherwise
    # @raise [Error] if group does not exist
    #
    def update
      save 
    end

    # Update attributes of a group 
    # @param [Hash] params the options to update a Group
    # @option params [String] :group_name Group name
    # @option params [String] :description Group description 
    # @option params [String] :email_permission Group permission: Owner or Member 
    # @note This method executes a <b>PUT</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId</i>
    #
    # @example Update the group "test"
    #   group = RubyProvisioningApi::Group.find("test")
    #   group.update_attributes(:group_id => "foo", :group_name => "foo name" , :description => "bar", :email_permission => "Owner") # => true
    #
    # @see https://developers.google.com/google-apps/provisioning/#updating_a_group
    # @return [Boolean] true if updated, false if not valid or not updated
    # @raise [Error] if group does not exist
    #    
    def update_attributes(params = {})
      self.group_name = params[:group_name] if params[:group_name]
      self.description = params[:description] if params[:description]
      self.email_permission = params[:email_permission] if params[:email_permission]
      update
    end    

    # Delete group  
    # @note This method executes a <b>DELETE</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId </i>
    #
    # @example Delete the group "test"
    #   group = RubyProvisioningApi::Group.find("test")
    #   group.delete
    #
    # @see https://developers.google.com/google-apps/provisioning/#deleting_a_group
    # @return [Boolean] true if deleted, false otherwise
    # @raise [Error] if group does not exist
    # 
    def delete
      params = self.class.prepare_params_for(:delete, "groupId" => group_id)
      # Perform the request & Check if the response contains an error
      self.class.check_response(self.class.perform(params))
    end

    # Retrieve all groups for a given member 
    # @param [String] member_id Member identification
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/?member=memberId[&directOnly=true|false]</i>
    #
    # @example Retrieve all groups for a member "foo"
    #   groups = RubyProvisioningApi::Group.groups("foo") # => [Array<Group>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_groups_for_a_member
    # @return [Array<Group>] all groups for a given member
    # @raise [Error] if member(user) does not exist
    #
    def self.groups(member_id)
      params = prepare_params_for(:retrieve_groups, "memberId" => member_id)
      response = perform(params)
      # Perform the request & Check if the response contains an error
      check_response(response)     
      # Parse the response
      xml = Nokogiri::XML(response.body)
      # Return the array of Groups
      parse_group_response(xml)
    end

    # Add member to group 
    # @param [String] member_id Member identification
    # @note This method executes a <b>POST</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member </i>
    #
    # @example Add member "foo" to group "bar"
    #   group = RubyProvisioningApi::Group.find("bar") # => [Group]
    #   group.add_member("foo") # => [true]
    #
    # @see https://developers.google.com/google-apps/provisioning/#adding_a_member_to_a_group
    # @return [Boolean] true if added as a member, false otherwise
    # @raise [Error] if member(user) does not exist
    #
    def add_member(member_id)
      add_entity("member",member_id) 
    end

    # Group membership of a given member
    # @param [String] member_id Member identification
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member/memberId</i>
    #
    # @example Check if user "foo" is member to the group "bar"
    #   group = RubyProvisioningApi::Group.find("bar") # => [Group]
    #   group.has_member?("foo") # => [true]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_members_of_a_group
    # @return [Boolean] true if user is a member of the group
    # @raise [Error] if member(user) does not exist
    #
    def has_member?(member_id)
      params = self.class.prepare_params_for(:has_member, { "groupId" => group_id, "memberId" => member_id })
      begin
        # Perform the request & Check if the response contains an error
        self.class.check_response(self.class.perform(params))
      rescue
        User.find(owner_id)
        false
      end    
    end


    # Delete group membership of a given member
    # @param [String] member_id Member identification
    # @note This method executes a <b>DELETE</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member/memberId</i>
    #
    # @example Delete user "foo" membership from group "bar"
    #   group = RubyProvisioningApi::Group.find("bar") # => [Group]
    #   group.delete_member("foo") # => [true]
    #
    # @see https://developers.google.com/google-apps/provisioning/#deleting_member_from_an_group
    # @return [Boolean] true if deleted, false otherwise
    # @raise [Error] if member(user) does not exist
    #
    def delete_member(member_id)
      delete_entity("member",member_id)   
    end

    # Add owner to group 
    # @param [String] owner_id Owner identification
    # @note This method executes a <b>POST</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/owner</i>
    #
    # @example Add owner "foo" to group "bar"
    #   group = RubyProvisioningApi::Group.find("bar") # => [Group]
    #   group.add_owner("foo") # => [true]
    #
    # @see https://developers.google.com/google-apps/provisioning/#assigning_an_owner_to_a_group
    # @return [Boolean] true if added as a owner, false otherwise
    # @raise [Error] if owner(user) does not exist
    #       
    def add_owner(owner_id)
      add_entity("owner",owner_id) 
    end

    # Group ownership of a given owner
    # @param [String] owner_id Owner identification
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/owner/ownerEmail
    # @example Check if user "foo" is owner to the group "bar"
    #   group = RubyProvisioningApi::Group.find("bar") # => [Group]
    #   group.has_owner?("foo") # => [true]
    #
    # @see https://developers.google.com/google-apps/provisioning/#querying_if_a_user_or_group_is_owner
    # @return [Boolean] true if user is a owner of the group, false otherwise
    # @raise [Error] if owner(user) does not exist
    #
    def has_owner?(owner_id)
      params = self.class.prepare_params_for(:has_owner, {"groupId" => group_id, "ownerId" => owner_id} )
      begin
        # Perform the request & Check if the response contains an error
        self.class.check_response(self.class.perform(params))
      rescue
        User.find(owner_id)
        false
      end   
    end


    # Delete group ownership of a given owner
    # @param [String] owner_id Owner identification
    # @note This method executes a <b>DELETE</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/owner/ownerEmail</i>
    #
    # @example Delete user "foo" ownership from group "bar"
    #   group = RubyProvisioningApi::Group.find("bar") # => [Group]
    #   group.delete_owner("foo") # => [true]
    #
    # @see https://developers.google.com/google-apps/provisioning/#deleting_an_owner_from_a_group
    # @return [Boolean] true if deleted, false otherwise
    # @raise [Error] if owner(user) does not exist
    #
    def delete_owner(owner_id)
      delete_entity("owner",owner_id)   
    end

    private

    def self.parse_group_response(xml)
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
      groups
    end

    def add_entity(entity,entity_id)
      # Check if the entity exists
      begin
        # is it a User?
        User.find(entity_id)
      rescue
        # if fails must throw an exception
        Group.find(entity_id)
      end
      # Creating the XML request
      builder = prepare_xml_request("#{entity}_id".to_sym => entity_id)
      params = self.class.prepare_params_for("add_#{entity}".to_sym, "groupId" => group_id )
      # Perform the request & Check if the response contains an error
      self.class.check_response(self.class.perform(params,builder.to_xml))  
    end

    def delete_entity(entity,entity_id)
      params = self.class.prepare_params_for("delete_#{entity}".to_sym, { "groupId" => group_id, "#{entity}Id" => entity_id })
      # Perform the request & Check if the response contains an error
      self.class.check_response(self.class.perform(params)) 
    end

    def prepare_xml_request(params = {})
      Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.send(:'atom:entry', 'xmlns:atom' => 'http://www.w3.org/2005/Atom', 'xmlns:apps' => 'http://schemas.google.com/apps/2006') {
          xml.send(:'atom:category', 'scheme' => 'http://schemas.google.com/g/2005#kind', 'term' => 'http://schemas.google.com/apps/2006#emailList')
          xml.send(:'apps:property', 'name' => 'email', 'value' => params[:owner_id]) if params.has_key? :owner_id
          xml.send(:'apps:property', 'name' => 'memberId', 'value' => params[:member_id]) if params.has_key? :member_id
          xml.send(:'apps:property', 'name' => 'groupId', 'value' => params[:group_id]) if ( params.has_key? :group_id && params[:update] )
          xml.send(:'apps:property', 'name' => 'groupName', 'value' => params[:group_name]) if params.has_key? :group_name
          xml.send(:'apps:property', 'name' => 'description', 'value' => params[:description]) if params.has_key? :description
          xml.send(:'apps:property', 'name' => 'emailPermission', 'value' => params[:email_permission]) if params.has_key? :email_permission
        }
      end
    end

  end
end	



