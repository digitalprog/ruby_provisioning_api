module RubyProvisioningApi
  
  module Owner


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

    # Retrieve owners for a group
    # @note This method executes a <b>GET</b> request to apps-apis.google.com/a/feeds/group/2.0/domain/groupId/owner[?[start=]]</i>
    #
    # @example Retrieve all owners for the group "foo"
    #   RubyProvisioningApi::Group.find("foo").owners # => [Array<User>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#querying_for_all_owners_of_a_group
    # @return [Array<User>] all owners for a group
    #
    def owners   
      owner_ids.map{ |owner| User.find(owner) }
    end

    # Retrieve owner ids for a group
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/owner[?[start=]]</i>
    #
    # @example Retrieve all owner ids for the group "foo"
    #   RubyProvisioningApi::Group.find("foo").owner_ids # => [Array<String>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#querying_for_all_owners_of_a_group
    # @return [Array<String>] all owner ids for a group
    #
    def owner_ids
      params = self.class.prepare_params_for(:owners, "groupId" => group_id)
      response = self.class.perform(params)
      self.class.check_response(response)
      # Parse the response
      xml = Nokogiri::XML(response.body)
      # Prepare a User array
      users_ids = []
      xml.children.css("entry").each do |entry|
        # If the member is a user
        if entry.css("apps|property[name]")[1].attributes["value"].value.eql?("User")
          # Fill the array with the username
          users_ids << entry.css("apps|property[name]")[0].attributes["value"].value.split("@")[0]
        end
      end
      # Return the array of users ids (members)
      users_ids    
    end

  end
end