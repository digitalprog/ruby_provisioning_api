module RubyProvisioningApi

  class Configuration

    attr_reader :config, :user_path, :group_path, :user_actions, :group_actions, :config_file
    attr_accessor :base_apps_url, :base_path, :http_debug, :ca_file

    def initialize
      if defined? Rails.root
        @config_file = "{Rails.root}/config/google_apps.yml"
        set_attributes
      end
    end

    def config_file=(filename = nil)
      @config_file = filename || "#{Rails.root}/config/google_apps.yml"
      set_attributes
    end

    private

    def set_attributes
      if File.exists? config_file
        @base_apps_url = 'https://apps-apis.google.com'
        @base_path = '/a/feeds'
        @http_debug = false
        @ca_file = nil

        @config = YAML.load_file(config_file)
        @user_path = "/#{@config[:domain]}/user/2.0"
        @group_path = "/group/2.0/#{@config[:domain]}"
        @user_actions = default_user_actions
        @group_actions = default_group_actions
      else
        raise RubyProvisioningApi::ConfigurationFileMissing.new(config_file)
      end
    end

    def default_user_actions
      {
          :create => {method: "POST", url: "#{user_path}"},
          :retrieve_all => {method: "GET", url: "#{user_path}"},
          :retrieve => {:method => "GET", :url => "#{user_path}/userName"},
          :delete => {:method => "DELETE", :url => "#{user_path}/userName"},
          :update => {:method => "PUT", :url => "#{user_path}/userName"},
          :member_of => {method: "GET", url: "#{group_path}/groupId/member/memberId"}
      }
    end

    def default_group_actions
      {
          :create => {method: "POST", url: "#{group_path}"},
          :update => {method: "PUT", url: "#{group_path}/groupId"},
          :delete => {method: "DELETE", url: "#{group_path}/groupId"},
          :retrieve_all => {method: "GET", url: "#{group_path}"},
          :retrieve_groups => {method: "GET", url: "#{group_path}/?member=memberId"},
          :retrieve => {method: "GET", url: "#{group_path}/groupId"},
          :add_member => {method: "POST", url: "#{group_path}/groupId/member"},
          :add_owner => {method: "POST", url: "#{group_path}/groupId/owner"},
          :delete_member => {method: "DELETE", url: "#{group_path}/groupId/member/memberId"},
          :has_member => {method: "GET", url: "#{group_path}/groupId/member/memberId"},
          :has_owner => {method: "GET", url: "#{group_path}/groupId/owner/ownerId"},
          :delete_owner => {method: "DELETE", url: "#{group_path}/groupId/owner/ownerId"},
          :member => {method: "GET", url: "#{group_path}/groupId/member/memberId"},
          :members => {method: "GET", url: "#{group_path}/groupId/member"},
          :owner => {method: "GET", url: "#{group_path}/groupId/owner/ownerId"},
          :owners => {method: "GET", url: "#{group_path}/groupId/owner"}
      }
    end

  end
end
