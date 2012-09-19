module RubyProvisioningApi
  class Group < Entity

    attr_accessor :group_id, :group_name, :description, :email_permission
    attr_reader :GROUP_PATH

    GROUP_PATH = "/group/2.0/#{RubyProvisioningApi.configuration[:domain]}/"

    ACTIONS = { 
      :create =>  { method: "POST" , url: "#{GROUP_PATH}"},
      :retrieve_all => { method: "GET" , url: "#{GROUP_PATH}" }
    }

  	def initialize(group_id, group_name, description, email_permission)
      self.group_id = group_id
      self.group_name = group_name
      self.description = description
      self.email_permission = email_permission
  	end

    def initialize
    end

    # Retrieve all groups in a domain  GET https://apps-apis.google.com/a/feeds/group/2.0/domain[?[start=]]
    def self.all
      response = perform(ACTIONS[:retrieve_all])
    end


    #Create                          POST https://apps-apis.google.com/a/feeds/group/2.0/domain
    def self.create
    end


    #Retrieve a group                 GET https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId
    def self.find(group_id)
    end


    #Update a group                   PUT https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId
    def self.update
    end

    #Delete group                  DELETE https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId
    def self.delete
    end

    # TODO
    #Retrieve all groups for a member GET https://apps-apis.google.com/a/feeds/group/2.0/domain/?member=memberId[&directOnly=true|false]
  end
end	



