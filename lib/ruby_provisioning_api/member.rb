module RubyProvisioningApi
  
  module Member
    
    GROUP_PATH = "/group/2.0/#{RubyProvisioningApi.configuration[:domain]}"
    USER_ATTRIBUTES = ['userName','password','suspended','quota','familyName','givenName']
    ACTIONS = {
        :member => {method: "GET", url: "#{GROUP_PATH}/groupId/member/memberId"},
        :members => {method: "GET", url: "#{GROUP_PATH}/groupId/member"},
    }

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

    # Retrieve all users which are members for a group
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_members_of_a_group GET https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member[?[start=]&[includeSuspendedUsers=true|false]] 
    # @return [Array<User>] all users which are members for a group
    def members
      # Creating a deep copy of ACTION object
      params = Entity.deep_copy(ACTIONS[:members])
      # Replacing placeholder groupId with correct group_id
      params[:url].gsub!("groupId",group_id)
      # Perform the request & Check if the response contains an error
      # TODO: missing check_response because it's redundant
      # Parse the response
      xml = Nokogiri::XML(self.class.perform(params).body)
      # Prepare a User array
      users = []
      xml.children.css("entry").each do |entry|
        # If the member is a user
        if entry.css("apps|property[name]")[0].attributes["value"].value.eql?("User")
          # Get the user_name
          user_name = entry.css("apps|property[name]")[1].attributes["value"].value.split("@")[0]
          users << User.find(user_name)
        end
      end
      # Return the array of users (members)
      users      
    end

  end
end