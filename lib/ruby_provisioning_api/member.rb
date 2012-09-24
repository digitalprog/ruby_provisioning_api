module RubyProvisioningApi
  
  class Member < User

    
    GROUP_PATH = "/group/2.0/#{RubyProvisioningApi.configuration[:domain]}"

    ACTIONS = {
        :member => {method: "GET", url: "#{GROUP_PATH}/groupId/member/memberId"},
    }



    # def self.find(member_id)
      # super(member_id)
    # end

    def self.members(group_id)
      # GET https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member[?[start=]&[includeSuspendedUsers=true|false]]
    end

    def self.members(group_id)
      all
    end

    def self.member?(member_id,group_id)
      # GET https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member/memberId
      # Creating a deep copy of ACTION object
      params = Marshal.load(Marshal.dump(ACTIONS[:member]))
      # Replacing placeholder groupId with correct group_id
      params[:url].gsub!("groupId",group_id)
      # Replacing placeholder groupId with correct group_id
      params[:url].gsub!("memberId",member_id)
      # Perform the request & Check if the response contains an error
      check_response(perform(params))  
    end

  end
end