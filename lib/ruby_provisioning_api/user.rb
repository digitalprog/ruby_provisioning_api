module RubyProvisioningApi
  class User < Entity

    attr_accessor :user_name, :family_name, :given_name, :password, :suspended, :admin, :quota_limit, :password_hash_function, :change_password
    attr_reader :USER_PATH

    USER_PATH = "/user/2.0/#{RubyProvisioningApi.configuration[:domain]}/"

    ACTIONS = { 
      :create =>  { method: "POST" , url: "#{USER_PATH}"},
      :retrieve_all => { method: "GET" , url: "#{USER_PATH}" }
    }

    def initialize(user_name,family_name,given_name,password,suspended,admin,quota_limit,password_hash_function,change_password)
      self.user_name = user_name
      self.family_name = family_name
      self.given_name = given_name
      self.password = password
      self.suspended = suspended
      self.admin = admin
      self.quota_limit = quota_limit
      self.password_hash_function = password_hash_function
      self.change_password = change_password
    end

    def initialize
    end

    # Retrieve all users in a domain GET https://apps-apis.google.com/a/feeds/domain/user/2.0
    def self.all
      response = perform(ACTIONS[:retrieve_all])
    end


    #Create                          POST https://apps-apis.google.com/a/feeds/group/2.0/domain
    def self.create
    end


    #Retrieve a user account GET https://apps-apis.google.com/a/feeds/domain/user/2.0/userName
    def self.find(user_name)
    end



    #TODO: To restore a user account using the protocol, change a suspended user's `suspended` value to `false` and make a `PUT` request with the updated entry.
    def self.restore
    end

    #TODO: To suspend a user account using the protocol, change the user's `suspended` value to `true` and make a `PUT` request with the updated entry.
    def self.suspend
    end

    #Delete user DELETE https://apps-apis.google.com/a/feeds/domain/user/2.0/userName
    def self.delete
    end

    # TODO
    #Retrieve all groups for a member GET https://apps-apis.google.com/a/feeds/group/2.0/domain/?member=memberId[&directOnly=true|false]
  end
end