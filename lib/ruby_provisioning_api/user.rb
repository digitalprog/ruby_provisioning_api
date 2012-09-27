module RubyProvisioningApi

  # @attr [String] user_name User's username
  # @attr [String] given_name User's first name
  # @attr [String] family_name User's last name
  # @attr [Boolean] suspended User's state (suspended if true, active if false)
  # @attr [String] quota User's disk space quota
  #
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

    # @param [Hash] params the options to create a User with.
    # @option params [String] :user_name User identification
    # @option params [String] :given_name User's first name
    # @option params [String] :family_name User's last name
    # @option params [String] :quota User's disk space quota (optional, default is 1024)
    # @option params [Boolean] :suspended true if user is suspended, false otherwise (optional, default is false)
    #
    def initialize(params = {})
      params.each do |name, value|
        send("#{name}=", value)
      end
      self.quota = "1024" if quota.nil?
      self.suspended = false if suspended.nil?
    end

    # Retrieve all users in the domain
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/domain/user/2.0</i>
    #
    # @example Retrieve all users in the current domain
    #   RubyProvisioningApi::User.all # => [Array<User>]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_users_in_a_domain
    # @return [Array<User>] all users in the domain
    #
    def self.all
      users = []
      response = perform(RubyProvisioningApi.configuration.user_actions[:retrieve_all])
      check_response(response)
      doc = Nokogiri::XML(response.body)
      doc.css("entry").each do |user_entry|
        users << extract_user(user_entry)
      end
      users
    end

    # Retrieve a user account
    # @note This method executes a <b>GET</b> request to <i>https://apps-apis.google.com/a/feeds/domain/user/2.0/userName</i>
    #
    # @example Retrieve the user account for "test"
    #   user = RubyProvisioningApi::User.find("test") # => [User]
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_user_accounts
    # @param [String] user_name
    # @return [User]
    # @raise [Error] if user does not exist
    #
    def self.find(user_name)
      params = prepare_params_for(:retrieve, "userName" => userName)
      response = perform(params)
      check_response(response)
      doc = Nokogiri::XML(response.body)
      extract_user(doc)
    end

    # Save a user account. If the user account exists it will be updated, if not, a new user account will be created
    #
    # @note This method executes a <b>POST</b> request to <i>apps-apis.google.com/a/feeds/domain/user/2.0</i> for the create action
    # @note This method executes a <b>PUT</b> request to <i>apps-apis.google.com/a/feeds/domain/user/2.0/userName</i> for the update action
    #
    # @example Create a user account in multiple steps
    #   user = RubyProvisioningApi::User.new
    #   user.user_name = "test" # => "test"
    #   user.given_name = "foo" # => "foo"
    #   user.family_name = "bar" # => "bar"
    #   user.save # => true
    #
    # @example Create a user account in a unique step
    #   user = RubyProvisioningApi::User.new(:user_name => "test",
    #                                        :given_name => "foo",
    #                                        :family_name => "bar",
    #                                        :quota => "2000") # => [User]
    #   user.save # => true
    #
    # @example Update a user account
    #   user = RubyProvisioningApi::User.find("test") # => [User]
    #   user.given_name = "foo2" # => "foo2"
    #   user.save # => true
    #
    # @see https://developers.google.com/google-apps/provisioning/#creating_a_user_account
    # @see https://developers.google.com/google-apps/provisioning/#updating_a_user_account
    # @param [Hash] save_options
    # @option save_options [Boolean] :validate skip validations before save if false, validate otherwise (defaults to true)
    # @return [Boolean] true if saved, false if not valid or not saved
    # @raise [Error] if the user already exists (user_name must be unique)
    #
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
        params = self.class.prepare_params_for(:update, "userName" => user_name_was)
        response = self.class.perform(params, builder.to_xml)
      else
        # SAVING a new record
        response = self.class.perform(RubyProvisioningApi.configuration.user_actions[:create], builder.to_xml)
      end
      User.check_response(response)
    end

    # Initialize and save a user.
    # @param [Hash] params the options to create a User with
    # @option params [String] :user_name User identification
    # @option params [String] :given_name User's first name
    # @option params [String] :family_name User's last name
    # @option params [String] :quota User's disk space quota (optional, default is 1024)
    # @option params [Boolean] :suspended true if user is suspended, false otherwise (optional, default is false)
    # @note This method executes a <b>POST</b> request to <i>apps-apis.google.com/a/feeds/domain/user/2.0</i>
    #
    # @example Create the user "test"
    #   user = RubyProvisioningApi::User.create(:user_name => "test",
    #                                           :given_name => "foo",
    #                                           :family_name => "bar",
    #                                           :quota => "2000") # => true
    #
    # @see https://developers.google.com/google-apps/provisioning/#creating_a_user_account
    # @return [Boolean] true if created, false if not valid or not created
    # @raise [Error] if user already exists (user_name must be unique)
    #
    def self.create(params = {})
      user = User.new(params)
      user.save
    end

    # Update user attributes (except suspend) and save
    #
    # @param [Hash] params the options to update the User with
    # @option params [String] :user_name User identification
    # @option params [String] :given_name User's first name
    # @option params [String] :family_name User's last name
    # @option params [String] :quota User's disk space quota
    #
    # @note This method executes a <b>PUT</b> request to <i>apps-apis.google.com/a/feeds/domain/user/2.0/userName</i> for the update action
    # @note With {User#update_attributes update_attributes} it's not possible to suspend or restore a user account. For these actions take a look
    #       at the {User#suspend suspend} and {User#restore restore} methods.
    #
    # @example Change the family name and the given_name of a user
    #   user = RubyProvisioningApi::User.find("foo") # => [User]
    #   user.update_attributes(:family_name => "smith", :given_name => "john") # => true
    #
    # @see https://developers.google.com/google-apps/provisioning/#updating_a_user_account
    # @return [Boolean] true if updated, false if not valid or not updated
    # @raise [Error] if user already exists (user_name must be unique)
    #
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

    # Suspend a user account
    # @note This method executes a <b>PUT</b> request to <i>apps-apis.google.com/a/feeds/domain/user/2.0/userName</i> for the update action
    #
    # @example Suspend the user account of the user "foo"
    #   user = RubyProvisioningApi::User.find("foo") # => [User]
    #   user.suspend # => true
    #
    # @see https://developers.google.com/google-apps/provisioning/#suspending_a_user_account
    # @return [Boolean] true if the operation succeeded, false otherwise
    #
    def suspend
      self.suspended = true
      save(:validate => false)
    end

    # Restore a user account
    # @note This method executes a <b>PUT</b> request to <i>apps-apis.google.com/a/feeds/domain/user/2.0/userName</i> for the update action
    #
    # @example Restore the user account of the user "foo"
    #   user = RubyProvisioningApi::User.find("foo") # => [User]
    #   user.restore # => true
    #
    # @see https://developers.google.com/google-apps/provisioning/#restoring_a_user_account
    # @return [Boolean] true if the operation succeeded, false otherwise
    #
    def restore
      self.suspended = false
      save(:validate => false)
    end

    #Delete user DELETE https://apps-apis.google.com/a/feeds/domain/user/2.0/userName
    def delete
      params = self.class.prepare_params_for(:delete, "userName" => user_name)
      response = self.class.perform(params)
    end

    # Returns all the groups which the user is subscribed to
    # TODO: move this inside member
    def groups
      Group.groups(user_name)
    end

    # Check if the user is a member of the given group
    # @note This method executes a <b>GET</b> request to <i>apps-apis.google.com/a/feeds/group/2.0/domain/groupId/member/memberId</i>
    #
    # @example Find a user and check if is member of the group 'test'
    #   user = RubyProvisioningApi::User.find("username")
    #   user.is_member_of? "test" # => true
    #
    # @see https://developers.google.com/google-apps/provisioning/#retrieving_all_members_of_a_group
    # @return [Boolean] true if the user is member of the group, false otherwise
    # @raise [Error] if group_id does not exist
    #
    def is_member_of?(group_id)
      params = self.class.prepare_params_for(:group_id, {"groupId" => group_id, "memberId" => user_name} )
      begin
        self.class.check_response(self.class.perform(params))
      rescue
        Group.find(group_id)
        false
      end
    end

    private

    def self.extract_user(doc)
      u = new
      u.user_name = doc.css("apps|login").first.attributes["userName"].value
      u.suspended = doc.css("apps|login").first.attributes["suspended"].value
      u.family_name = doc.css("apps|name").first.attributes["familyName"].value
      u.given_name = doc.css("apps|name").first.attributes["givenName"].value
      u.quota = doc.css("apps|quota").first.attributes["limit"].value
      u
    end

  end

end