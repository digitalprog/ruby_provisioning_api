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

    # Retrieve members for a group
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member[?[start=]&[includeSuspendedUsers=true|false]]</i>
    #
    # @example Retrieve all members for the group "foo"
    #   RubyProvisioningApi::Group.find("foo").members # => [Array<User>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_members_of_a_group
    # @return [Array<User>] all members for a group
    #
    def members   
      member_ids.map{ |member| User.find(member) }
    end

    # Retrieve member ids for a group
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member[?[start=]&[includeSuspendedUsers=true|false]]</i>
    #
    # @example Retrieve all member ids for the group "foo"
    #   RubyProvisioningApi::Group.find("foo").member_ids # => [Array<String>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_members_of_a_group
    # @return [Array<User>] all member ids for a group
    #
    def member_ids
      params = self.class.prepare_params_for(:members, "groupId" => group_id)
      response = self.class.perform(params)
      self.class.check_response(response)
      # Parse the response
      xml = Nokogiri::XML(response.body)
      # Prepare a User array
      users_ids = []
      xml.children.css("entry").each do |entry|
        # If the member is a user
        if entry.css("apps|property[name]")[0].attributes["value"].value.eql?("User")
          # Fill the array with the username
          users_ids << entry.css("apps|property[name]")[1].attributes["value"].value.split("@")[0]
        end
      end
      # Return the array of users ids (members)
      users_ids         
    end

  end
end