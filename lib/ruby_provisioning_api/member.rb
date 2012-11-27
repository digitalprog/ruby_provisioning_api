module RubyProvisioningApi

  # This module defines the group members methods. It is included by the Group class.
  #
  module Member

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
      # Prepare a User array
      xml = Nokogiri::XML(response.body)
      entity_ids = parse_member_response(xml, entity)
      while (np = self.class.next_page(xml))
        params = self.class.prepare_params_for(:members_page, "groupId" => group_id,
                                               "startFrom" => np.to_s.split("start=").last)
        response = self.class.perform(params)
        xml = Nokogiri::XML(response.body)
        entity_ids += parse_member_response(xml, entity)
      end
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

    def parse_member_response(xml, entity)
      entity_ids = []
      xml.children.css("entry").each do |entry|
        # If the member is a user
        entry_details = entry.css("apps|property[name]")
        if entry_details[0].attributes["value"].value.eql?(entity)
          # Fill the array with the username
          entity_ids << entry_details[1].attributes["value"].value
        end
      end
      entity_ids
    end

  end
end