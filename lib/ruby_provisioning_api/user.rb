module RubyProvisioningApi
  class User < Entity

    attr_accessor :user_name, :family_name, :given_name

    USER_PATH = "/#{RubyProvisioningApi.configuration[:domain]}/user/2.0"

    ACTIONS = {
        :create => {method: "POST", url: "#{USER_PATH}"},
        :retrieve_all => {method: "GET", url: "#{USER_PATH}"},
        :retrieve => {:method => "GET", :url => "#{USER_PATH}/userName"},
        :delete => {:method => "DELETE", :url => "#{USER_PATH}/userName"},
        :update => {:method => "PUT", :url => "#{USER_PATH}/userName"}
    }

    # User initialization
    # Params:
    # user_name, given_name, fmaily_name or none of them
    def initialize(params = nil)
      if params.nil? || (params.has_key?(:user_name) && params.has_key?(:given_name) && params.has_key?(:family_name))
        if params
          self.user_name = params[:user_name]
          self.given_name = params[:given_name]
          self.family_name = params[:family_name]
        end
      else
        raise InvalidArgument
      end
    end

    # Retrieve a user account GET https://apps-apis.google.com/a/feeds/domain/user/2.0/userName
    def self.find(user_name)
      params = Marshal.load(Marshal.dump(ACTIONS[:retrieve]))
      params[:url].gsub!("userName", user_name)
      response = perform(params)
      check_response(response)
      doc = Nokogiri::XML(response.body)
      u = User.new
      u.user_name = doc.css("apps|login").first.attributes["userName"].value
      u.family_name = doc.css("apps|name").first.attributes["familyName"].value
      u.given_name = doc.css("apps|name").first.attributes["givenName"].value
      u
    end

    # Retrieve all users in a domain GET https://apps-apis.google.com/a/feeds/domain/user/2.0
    def self.all
      users = []
      response = perform(ACTIONS[:retrieve_all])
      check_response(response)
      doc = Nokogiri::XML(response.body)
      doc.css("entry").each do |user_entry|
        u = User.new
        u.user_name = user_entry.css("apps|login").first.attributes["userName"].value
        u.given_name = user_entry.css("apps|name").first.attributes["givenName"].value
        u.family_name = user_entry.css("apps|name").first.attributes["familyName"].value
        users << u
      end
      users
    end

    def save
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.send(:'atom:entry', 'xmlns:atom' => 'http://www.w3.org/2005/Atom', 'xmlns:apps' => 'http://schemas.google.com/apps/2006') {
          xml.send(:'atom:category', 'scheme' => 'http://schemas.google.com/g/2005#kind', 'term' => 'http://schemas.google.com/apps/2006#user')
          xml.send(:'apps:login', 'userName' => user_name, 'password' => '51eea05d46317fadd5cad6787a8f562be90b4446', 'suspended' => false)
          xml.send(:'apps:quota', 'limit' => "1024")
          xml.send(:'apps:name', 'familyName' => family_name, 'givenName' => given_name)
        }
      end
      response = self.class.perform(ACTIONS[:create], builder.to_xml)
      User.check_response(response)
    end

    # Create POST https://apps-apis.google.com/a/feeds/domain/user/2.0
    def self.create(params)
      user = User.new(params)
      user.save
    end


    # FIX:will work only when find will return a User object
    def update_attributes(params)
      old_user_name = self.user_name
      self.user_name = params[:user_name] if params[:user_name]
      self.family_name = params[:family_name] if params[:family_name]
      self.given_name = params[:given_name] if params[:given_name]
      update(old_user_name)
    end

    #TODO: To restore a user account using the protocol, change a suspended user's `suspended` value to `false` and make a `PUT` request with the updated entry.
    def self.restore
    end

    #TODO: To suspend a user account using the protocol, change the user's `suspended` value to `true` and make a `PUT` request with the updated entry.
    def self.suspend
    end

    #Delete user DELETE https://apps-apis.google.com/a/feeds/domain/user/2.0/userName
    def self.delete(user_name)
      params = Marshal.load(Marshal.dump(ACTIONS[:delete]))
      params[:url].gsub!("userName", user_name)
      response = perform(params)
    end

    # Returns all the groups which the user is subscribed to
    # TODO: move this inside member
    def groups
      Group.groups(user_name)
    end

    # Returns all the users of a specific group
    def users(group_id)
    end

    # TODO
    #Retrieve all groups for a member GET https://apps-apis.google.com/a/feeds/group/2.0/domain/?member=memberId[&directOnly=true|false]

    private

    def update(old_user_name)
      params = Marshal.load(Marshal.dump(ACTIONS[:update]))
      params[:url].gsub!("userName", old_user_name)
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.send(:'atom:entry', 'xmlns:atom' => 'http://www.w3.org/2005/Atom', 'xmlns:apps' => 'http://schemas.google.com/apps/2006') {
          xml.send(:'atom:category', 'scheme' => 'http://schemas.google.com/g/2005#kind', 'term' => 'http://schemas.google.com/apps/2006#user')
          xml.send(:'apps:login', 'userName' => user_name, 'password' => '51eea05d46317fadd5cad6787a8f562be90b4446', 'suspended' => false)
          xml.send(:'apps:name', 'familyName' => family_name, 'givenName' => given_name)
        }
      end
      response = self.class.perform(params, builder.to_xml)
      User.check_response(response)
    end
  end
end