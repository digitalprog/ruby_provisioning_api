module RubyProvisioningApi
  
  module Member
    
    GROUP_PATH = "/group/2.0/#{RubyProvisioningApi.configuration[:domain]}"

    ACTIONS = {
        :member => {method: "GET", url: "#{GROUP_PATH}/groupId/member/memberId"},
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

    def members(group_id)
      all
    end



  end
end