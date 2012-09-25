module RubyProvisioningApi
  
  module Owner
    
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

    # Retrieve all users which are owner for a group
    # @see https://developers.google.com/google-apps/provisioning/#querying_for_all_owners_of_a_group GET https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId/owner[?[start=]] 
    # @return [Array<User>] all users which are members for a group
    def owners
      # Creating a deep copy of ACTION object
      params = Entity.deep_copy(ACTIONS[:members])
      # Replacing placeholder groupId with correct group_id
      params[:url].gsub!("groupId",group_id)
      # Perform the request & Check if the response contains an error
      response = self.class.perform(params)
      self.class.check_response(response)
      # Parse the response
      xml = Nokogiri::XML(response.body)
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