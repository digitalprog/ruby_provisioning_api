module RubyProvisioningApi

  class Configuration

    attr_accessor :config_file, :base_apps_url, :base_path, :http_debug, :ca_file
    attr_reader :config, :user_path, :group_path, :user_actions, :group_actions

    def initialize(cfg = "")
      if cfg.blank?
        if defined?(Rails.root)
          @config_file = "{Rails.root}/config/google_apps.yml"
        else
          @config_file = "invalid"
        end
      else
        @config_file = cfg
      end

      if File.exist?(config_file)
        set_attributes
      else
        raise "RubyProvisioningApi: Configuration file #{config_file} not found, maybe you forgot to define it ?" unless config_file == "invalid"
      end
    end

    private

    def set_attributes
      @config = YAML.load_file(config_file)
      @ca_file = nil
      @http_debug = false
      @base_apps_url = 'https://apps-apis.google.com'
      @base_path = '/a/feeds'
      @user_path = "/#{@config[:domain]}/user/2.0"
      @group_path = "/group/2.0/#{@config[:domain]}"
      @user_actions = {
          :create => {method: "POST", url: "#{user_path}"},
          :retrieve_all => {method: "GET", url: "#{user_path}"},
          :retrieve => {:method => "GET", :url => "#{user_path}/userName"},
          :delete => {:method => "DELETE", :url => "#{user_path}/userName"},
          :update => {:method => "PUT", :url => "#{user_path}/userName"},
          :member_of => {method: "GET", url: "#{group_path}/groupId/member/memberId"}
      }
      @group_actions = {
          :create =>  { method: "POST" , url: "#{group_path}"},
          :update =>  { method: "PUT" , url: "#{group_path}/groupId"},
          :delete =>  { method: "DELETE" , url: "#{group_path}/groupId"},
          :retrieve_all => { method: "GET" , url: "#{group_path}" },
          :retrieve_groups => { method: "GET" , url: "#{group_path}/?member=memberId" },
          :retrieve => { method: "GET" , url: "#{group_path}/groupId" },
          :add_member => { method: "POST" , url: "#{group_path}/groupId/member" },
          :add_owner => { method: "POST" , url: "#{group_path}/groupId/owner" },
          :delete_member => { method: "DELETE" , url: "#{group_path}/groupId/member/memberId" },
          :has_member => {method: "GET", url: "#{group_path}/groupId/member/memberId"},
          :has_owner => {method: "GET", url: "#{group_path}/groupId/owner/ownerId"},
          :delete_owner => {method: "DELETE" , url: "#{group_path}/groupId/owner/ownerId"},
          :member => {method: "GET", url: "#{group_path}/groupId/member/memberId"},
          :members => {method: "GET", url: "#{group_path}/groupId/member"},
          :owner => {method: "GET", url: "#{group_path}/groupId/owner/ownerId"},
          :owners => {method: "GET", url: "#{group_path}/groupId/owner"}
      }
    end

  end
end
