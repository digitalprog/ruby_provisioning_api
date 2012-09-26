module RubyProvisioningApi
  
  module Member

    def self.included(base)
      base.extend(ClassMethods)
    end
    # Instance methods here

    
    module ClassMethods
      # Class methods here
    end
    # def self.find(member_id)
      # super(member_id)
    # end

    # Retrieve user members for a group
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member[?[start=]&[includeSuspendedUsers=true|false]]</i>
    #
    # @example Retrieve all user members for the group "foo"
    #   RubyProvisioningApi::Group.find("foo").user_members # => [Array<User>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_members_of_a_group
    # @return [Array<User>] all user members for a group
    #
    def user_members
      members("User")
    end

    # Retrieve group members for a group
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member[?[start=]&[includeSuspendedUsers=true|false]]</i>
    #
    # @example Retrieve all group members for the group "foo"
    #   RubyProvisioningApi::Group.find("foo").group_members # => [Array<User>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_members_of_a_group
    # @return [Array<User>] all group members for a group
    #
    def group_members
      members("Group")
    end

    # Retrieve user member ids
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member[?[start=]&[includeSuspendedUsers=true|false]]</i>
    #
    # @example Retrieve all user member ids for group "foo" 
    #   RubyProvisioningApi::Group.find("foo").user_member_ids # => [Array<String>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_members_of_a_group
    # @return [Array<String>] all user member ids
    #
    def user_member_ids
      member_ids("User")
    end

    # Retrieve group member ids
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member[?[start=]&[includeSuspendedUsers=true|false]]</i>
    #
    # @example Retrieve all user member ids for group "foo" 
    #   RubyProvisioningApi::Group.find("foo").group_member_ids # => [Array<String>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_members_of_a_group
    # @return [Array<String>] all group member ids
    #
    def group_member_ids
      member_ids("Group")
    end

    private

    # Retrieve member ids for an entity [Group or User]
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member[?[start=]&[includeSuspendedUsers=true|false]]</i>
    #
    # @example Retrieve all group member ids for the group "foo" 
    #   RubyProvisioningApi::Group.find("foo").member_ids("Group") # => [Array<String>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_members_of_a_group
    # @return [Array<String>] all entity member ids for an entity [Group or User]
    # @param [String] entity Entity name
    #
    def member_ids(entity)
      params = self.class.prepare_params_for(:members, "groupId" => group_id)
      response = self.class.perform(params)
      self.class.check_response(response)
      # Parse the response
      xml = Nokogiri::XML(response.body)
      # Prepare a User array
      entity_ids = []
      xml.children.css("entry").each do |entry|
        # If the member is a user
        if entry.css("apps|property[name]")[0].attributes["value"].value.eql?(entity)
          # Fill the array with the username
          entity_ids << entry.css("apps|property[name]")[1].attributes["value"].value.split("@")[0]
        end
      end
      # Return the array of users ids (members)
      entity_ids         
    end

    # Retrieve entity members for a group
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member[?[start=]&[includeSuspendedUsers=true|false]]</i>
    #
    # @example Retrieve all group members for the group "foo"
    #   RubyProvisioningApi::Group.find("foo").members("Group") # => [Array<User>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_members_of_a_group
    # @return [Array<User>] all entity members for a group
    # @param [String] entity Entity name
    #
    def members(entity)   
      member_ids(entity).map{ |member| "RubyProvisioningApi::#{entity}".constantize.send(:find, member) }
    end
    
  end
end