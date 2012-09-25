module RubyProvisioningApi

  # @attr [String] user_name user's username
  # @attr [String] given_name user's first name
  # @attr [String] family_name user's last name
  # @attr [Boolean] suspended user's state (suspended if true, active if false)
  # @attr [String] quota user's disk space quota
  class User
    extend Entity
    extend Member
    extend Owner

    include ActiveModel::Validations
    include ActiveModel::Dirty

    attr_accessor :user_name, :family_name, :given_name, :suspended, :quota
    alias_method :suspended?, :suspended
    define_attribute_methods [:user_name]
    validates :user_name, :family_name, :given_name, :presence => true

    USER_PATH = "/#{RubyProvisioningApi.configuration[:domain]}/user/2.0"

    ACTIONS = {
        :create => {method: "POST", url: "#{USER_PATH}"},
        :retrieve_all => {method: "GET", url: "#{USER_PATH}"},
        :retrieve => {:method => "GET", :url => "#{USER_PATH}/userName"},
        :delete => {:method => "DELETE", :url => "#{USER_PATH}/userName"},
        :update => {:method => "PUT", :url => "#{USER_PATH}/userName"},
        :member_of => {method: "GET", url: "#{Group::GROUP_PATH}/groupId/member/memberId"}
    }

    # @param [Hash] attributes the options to create a User with.
    # @option attributes [String] :user_name user identification
    # @option attributes [String] :given_name user's first name
    # @option attributes [String] :family_name user's last name
    # @option attributes [String] :quota user's disk space quota (default is 1024)
    # @option attributes [Boolean] :suspended true if user is suspended, false otherwise (default is false)
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
      self.quota = "1024" if quota.nil?
      self.suspended = false if suspended.nil?
    end

    # Retrieve a user account GET https://apps-apis.google.com/a/feeds/domain/user/2.0/userName
    def self.find(user_name)
      params = Marshal.load(Marshal.dump(ACTIONS[:retrieve]))
      params[:url].gsub!("userName", user_name)
      response = perform(params)
      check_response(response)
      doc = Nokogiri::XML(response.body)
      u = new
      u.user_name = doc.css("apps|login").first.attributes["userName"].value
      u.suspended = doc.css("apps|login").first.attributes["suspended"].value
      u.family_name = doc.css("apps|name").first.attributes["familyName"].value
      u.given_name = doc.css("apps|name").first.attributes["givenName"].value
      u.quota = doc.css("apps|quota").first.attributes["limit"].value
      u
    end

    # Retrieve all users in a domain GET https://apps-apis.google.com/a/feeds/domain/user/2.0
    def self.all
      users = []
      response = perform(ACTIONS[:retrieve_all])
      check_response(response)
      doc = Nokogiri::XML(response.body)
      doc.css("entry").each do |user_entry|
        u = new
        u.user_name = user_entry.css("apps|login").first.attributes["userName"].value
        u.suspended = doc.css("apps|login").first.attributes["suspended"].value
        u.given_name = user_entry.css("apps|name").first.attributes["givenName"].value
        u.family_name = user_entry.css("apps|name").first.attributes["familyName"].value
        u.quota = doc.css("apps|quota").first.attributes["limit"].value
        users << u
      end
      users
    end

    def save(save_options = {:validate => true})
      if save_options[:validate]
        return false unless valid?
      end
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.send(:'atom:entry', 'xmlns:atom' => 'http://www.w3.org/2005/Atom', 'xmlns:apps' => 'http://schemas.google.com/apps/2006') {
          xml.send(:'atom:category', 'scheme' => 'http://schemas.google.com/g/2005#kind', 'term' => 'http://schemas.google.com/apps/2006#user')
          xml.send(:'apps:login', 'userName' => user_name, 'password' => '51eea05d46317fadd5cad6787a8f562be90b4446', 'suspended' => suspended)
          xml.send(:'apps:quota', 'limit' => quota)
          xml.send(:'apps:name', 'familyName' => family_name, 'givenName' => given_name)
        }
      end
      if User.present?(user_name_was)
        # UPDATING an old record
        params = Marshal.load(Marshal.dump(ACTIONS[:update]))
        params[:url].gsub!("userName", user_name_was)
        response = self.class.perform(params, builder.to_xml)
      else
        # SAVING a new record
        response = self.class.perform(ACTIONS[:create], builder.to_xml)
      end
      User.check_response(response)
    end

    # Create POST https://apps-apis.google.com/a/feeds/domain/user/2.0
    def self.create(params)
      user = User.new(params)
      user.save
    end

    # TODO: documentare che con update attributes non si può fare la sospensione e il restore di utenti
    #       per queste operazioni si usano i metodi appositi suspend e restore.
    def update_attributes(params)
      if params.has_key? :user_name and params[:user_name] != self.user_name
        user_name_will_change!
        self.user_name = params[:user_name]
      end
      self.family_name = params[:family_name] if params.has_key? :family_name
      self.given_name = params[:given_name] if params.has_key? :given_name
      self.quota = params[:quota] if params.has_key? :quota
      save
    end

    #TODO: To restore a user account using the protocol, change a suspended user's `suspended` value to `false` and make a `PUT` request with the updated entry.
    def restore
      self.suspended = false
      save(:validate => false)
    end

    #TODO: To suspend a user account using the protocol, change the user's `suspended` value to `true` and make a `PUT` request with the updated entry.
    def suspend
      self.suspended = true
      save(:validate => false)
    end

    #Delete user DELETE https://apps-apis.google.com/a/feeds/domain/user/2.0/userName
    def delete(user_name)
      params = Marshal.load(Marshal.dump(ACTIONS[:delete]))
      params[:url].gsub!("userName", user_name)
      response = perform(params)
    end

    # Returns all the groups which the user is subscribed to
    # TODO: move this inside member
    def groups
      Group.groups(user_name)
    end

    # TODO
    #Retrieve all groups for a member GET https://apps-apis.google.com/a/feeds/group/2.0/domain/?member=memberId[&directOnly=true|false]

    def is_member_of?(group_id)
      # GET https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member/memberId
      # Creating a deep copy of ACTION object
      params = Marshal.load(Marshal.dump(ACTIONS[:member_of]))
      # Replacing placeholder groupId with correct group_id
      params[:url].gsub!("groupId", group_id)
      # Replacing placeholder groupId with correct group_id
      params[:url].gsub!("memberId", user_name)
      # Perform the request & Check if the response contains an error
      self.class.check_response(self.class.perform(params))
    end

  end

end