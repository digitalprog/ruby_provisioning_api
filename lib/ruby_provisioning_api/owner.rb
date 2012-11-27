module RubyProvisioningApi

  # This module defines the group owners methods. It is included by the Group class.
  #
  module Owner

    # Retrieve user owners for a group
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/owner[?[start=]]</i>
    #
    # @example Retrieve all user owners for the group "foo"
    #   RubyProvisioningApi::Group.find("foo").user_owners # => [Array<User>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#querying_for_all_owners_of_a_group
    # @return [Array<User>] all user owners for a group
    #
    def user_owners
      owners("User")
    end

    # Retrieve group owners for a group
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/owner[?[start=]]</i>
    #
    # @example Retrieve all group owners for the group "foo"
    #   RubyProvisioningApi::Group.find("foo").group_owners # => [Array<User>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#querying_for_all_owners_of_a_group
    # @return [Array<User>] all group owners for a group
    #
    def group_owners
      owners("Group")
    end

    # Retrieve user owner ids
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/owner[?[start=]]</i>
    #
    # @example Retrieve all user owner ids for group "foo" 
    #   RubyProvisioningApi::Group.find("foo").user_owner_ids # => [Array<String>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#querying_for_all_owners_of_a_group
    # @return [Array<String>] all user owner ids
    #
    def user_owner_ids
      owner_ids("User")
    end

    # Retrieve group owner ids
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/owner[?[start=]]</i>
    #
    # @example Retrieve all user owner ids for group "foo" 
    #   RubyProvisioningApi::Group.find("foo").group_member_ids # => [Array<String>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#querying_for_all_owners_of_a_group
    # @return [Array<String>] all group owner ids
    #
    def group_owner_ids
      owner_ids("Group")
    end

    private

    # Retrieve owner ids for an entity [Group or User]
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/owner[?[start=]]</i>
    #
    # @example Retrieve all group owner ids for the group "foo" 
    #   RubyProvisioningApi::Group.find("foo").owner_ids("Group") # => [Array<String>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#querying_for_all_owners_of_a_group
    # @return [Array<String>] all entity owner ids for an entity [Group or User]
    # @param [String] entity Entity name
    #    
    def owner_ids(entity)
      params = self.class.prepare_params_for(:owners, "groupId" => group_id)
      response = self.class.perform(params)
      self.class.check_response(response)
      # Prepare a User array
      xml = Nokogiri::XML(response.body)
      entity_ids = parse_owner_response(xml, entity)
      while (np = self.class.next_page(xml))
        params = self.class.prepare_params_for(:owners_page, "groupId" => group_id,
                                               "startFrom" => np.to_s.split("start=").last)
        response = self.class.perform(params)
        xml = Nokogiri::XML(response.body)
        entity_ids += parse_owner_response(xml, entity)
      end
      entity_ids
    end

    # Retrieve entity owners for a group
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/owner[?[start=]]</i>
    #
    # @example Retrieve all group owners for the group "foo"
    #   RubyProvisioningApi::Group.find("foo").owners("Group") # => [Array<User>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#querying_for_all_owners_of_a_group
    # @return [Array<User>] all entity owners for a group
    # @param [String] entity Entity name
    #
    def owners(entity)
      owners_ids(entity).map{ |owner| "RubyProvisioningApi::#{entity}".constantize.send(:find, owner) }
    end

    def parse_owner_response(xml, entity)
      entity_ids = []
      xml.children.css("entry").each do |entry|
        # If the member is a user
        entry_details = entry.css("apps|property[name]")
        if entry_details[1].attributes["value"].value.eql?(entity)
          # Fill the array with the username
          entity_ids << entry_details[0].attributes["value"].value
        end
      end
      entity_ids
    end

  end
end