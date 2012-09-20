module RubyProvisioningApi
  class Group < Entity

    attr_accessor :group_id, :group_name, :description, :email_permission
    attr_reader :GROUP_PATH

    GROUP_PATH = "/group/2.0/#{RubyProvisioningApi.configuration[:domain]}"

    ACTIONS = { 
      :create =>  { method: "POST" , url: "#{GROUP_PATH}"},
      :retrieve_all => { method: "GET" , url: "#{GROUP_PATH}" },
      :retrieve => { method: "GET" , url: "#{GROUP_PATH}/groupId" }
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

    def save
      Group.create(group_id, group_name, description, email_permission)
    end

    #Create POST https://apps-apis.google.com/a/feeds/group/2.0/domain
    def self.create(group_id, group_name, description, email_permission)
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.send(:'atom:entry', 'xmlns:atom' => 'http://www.w3.org/2005/Atom', 'xmlns:apps' => 'http://schemas.google.com/apps/2006') {
          xml.send(:'atom:category', 'scheme' => 'http://schemas.google.com/g/2005#kind', 'term' => 'http://schemas.google.com/apps/2006#emailList')
          xml.send(:'apps:property', 'name' => 'groupId', 'value' => group_id)
          xml.send(:'apps:property', 'name' => 'groupName', 'value' => group_name)
          xml.send(:'apps:property', 'name' => 'description', 'value' => description)
          xml.send(:'apps:property', 'name' => 'emailPermission', 'value' => email_permission)
        }
      end
      response = perform(ACTIONS[:create],builder.to_xml)
      #TODO controllare eventuali eccezioni e restituire true/false in caso      
    end


    #Retrieve a group  GET https://apps-apis.google.com/a/feeds/group/2.0/domain/groupId
    def self.find(group_id)
      # Creating a deep copy of ACTION object
      params = Marshal.load(Marshal.dump(ACTIONS[:retrieve]))
      # Replacing place holder groupId with correct group_id
      params[:url].gsub!("groupId",group_id)
      response = perform(params)
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



