require 'spec_helper'
require 'webmock/rspec'
require 'ruby_provisioning_api'

describe "Group" do

  FAKE_GROUP_ID = "foo_id"
  FAKE_GROUP_NAME = "foo_name"
  FAKE_DESCRIPTION = "foo_description"
  FAKE_EMAIL_PERMISSION = "Owner"
  FAKE_MEMBER_ID = "foo_member"
  FAKE_OWNER_ID = "foo_owner"

  before :all do
    RubyProvisioningApi.configure do |config|
      config.config_file = File.expand_path(File.join(__FILE__, "..", "..", "..", "lib", "ruby_provisioning_api", "config", "google_apps.yml"))
    end
    # Fake authentication XML body
    xml_body = "SID=DQAAAOUAAACA_vaRWNvKij2fLLgRRU10BO79pFK1H_TCStyIyTyQ7Q04BzsoWM2ggTaC6VPRcSw1ZxF86ZZ0Nkg4Cbd2u7m1kmSPEUC88jtzqIa4Vk1NqNpn5VzKmsBb3wXRUJjClPsn6t8SfHNhzmZE-DwzIbBK37oSW3rtPxhZjVhBNUtXTLeoxaRFUaw08_MqrLbIsM2Xa049lW1HhSUiVTINwW3qireKimvQe_Sl6Vs7uYYx8MI_nLOn-SX_iE65b41_L3RWuKkapTCS5nucqqcJRNapZ-3Qx8OaDBisg0Yz4rNKsXmuO5CTkaEjXWkRM0VsFUU
		LSID=DQAAAOcAAABAo1sgz1Cn_INiScJcbGwIoK5mAYMoOEOiIl_I3q4ei1KngWGQB_gNub471pCPo6zbkB72nlDMvhYYJTUqwx7gyyxQA0qvrDSBaTh4J8y0HF5eFrbFqc17D97AiqkZjedK2msrWV9b3M7ObEqhML3Ewmw845ZXaAgAz8m_dS2-5FEBAazm5x-yMTDYx-rVlpdAVDjPX5OG39MwWVLJv-q54NDBMPIvwl4th16-near-Ta6KrBotmwO7xSYOI_X84HyQlB1jwGei8kVnNZ8B5qenjli8WPJ-fGr9tXTDFXHJzsm1wUpsZN8Sv-LZKYUKkA
		Auth=DQAAAOYAAABAo1sgz1Cn_INiScJcbGwIoK5mAYMoOEOiIl_I3q4ei1KngWGQB_gNub471pCPo6xLpX3vI4aeREw7UkLDNza6qIalwH2MRBmxFeFCfXIoxXYj8FcP262Vf6V59EDPKUls3iYXnHtBCqhRo1KMkvehe242uvNN5figfS6s_hsKbB0eSP3on6kB31JyHJB4VVN72woDX2xsjPA5izqJfbTAlm3EUQsQGOqO_mnhXpD5sk5qTSxhfirm3ffz3PTRS0OVFaiydOVwzpHXZHB2DBbizRJLiGGDL4JP7Ea-E4i_nEbQTLmoqAV0WtOAsfOLMgs"

    stub_request(:post, "https://www.google.com/accounts/ClientLogin").
        with(:body => {:Email => "#{RubyProvisioningApi.configuration.config[:username]}@#{RubyProvisioningApi.configuration.config[:domain]}", :Passwd => RubyProvisioningApi.configuration.config[:password], :accountType => "HOSTED", :service => "apps"},
             :headers => {'Accept' => '*/*', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby'}).
        to_return(:status => 200,
                  :body => xml_body,
                  :headers => {})
    @token = RubyProvisioningApi.connection.token
  end

  def handle_request(params = {})
    stub_request(params[:method], params[:url]).
        with(:headers => {'Accept' => '*/*', 'Authorization' => "GoogleLogin auth=#{@token}", 'Content-Type' => 'application/atom+xml', 'User-Agent' => 'Ruby'},
             :body => params[:request_body]).
        to_return(:status => 200,
                  :body => params[:response_body],
                  :headers => {})
  end

  def find_stub(group_id = FAKE_GROUP_ID, group_name = FAKE_GROUP_NAME, description = FAKE_DESCRIPTION, email_permission = FAKE_EMAIL_PERMISSION)
    # Fake XML response body
    response_body = <<-eos
			<?xml version='1.0' encoding='UTF-8'?>
			<entry xmlns='http://www.w3.org/2005/Atom' xmlns:apps='http://schemas.google.com/apps/2006'>
				<id>foo bar</id>
				<updated>fake date</updated>
				<link rel='self' type='application/atom+xml' href='foo link'/>
				<link rel='edit' type='application/atom+xml' href='foo link'/>
				<apps:property name='groupId' value="#{group_id}@#{RubyProvisioningApi.configuration.config[:domain]}"/>
				<apps:property name='groupName' value="#{group_name}"/>
				<apps:property name='emailPermission' value="#{email_permission}"/>
				<apps:property name='permissionPreset' value='Custom'/>
				<apps:property name='description' value="#{description}"/>
			</entry>
    eos

    handle_request(:method => :get,
                   :url => "https://apps-apis.google.com/a/feeds/group/2.0/#{RubyProvisioningApi.configuration.config[:domain]}/#{group_id}",
                   :response_body => response_body, :request_body => "")
  end

  def all_stub(group_id = FAKE_GROUP_ID, group_name = FAKE_GROUP_NAME, description = FAKE_DESCRIPTION, email_permission = FAKE_EMAIL_PERMISSION)
    # Fake XML response body
    response_body = <<-eos
		<?xml version='1.0' encoding='UTF-8'?>
		<feed xmlns='http://www.w3.org/2005/Atom' xmlns:openSearch='http://a9.com/-/spec/opensearchrss/1.0/' xmlns:apps='http://schemas.google.com/apps/2006'>
		<id>fake id</id>
		<updated>fake date </updated>
		<link rel='http://schemas.google.com/g/2005#feed' type='application/atom+xml' href='foo link'/>
		<link rel='http://schemas.google.com/g/2005#post' type='application/atom+xml' href='foo link'/>
		<link rel='self' type='application/atom+xml' href='foo link'/><openSearch:startIndex>1</openSearch:startIndex>
		<entry>
			<id>https://apps-apis.google.com/a/feeds/group/2.0/#{RubyProvisioningApi.configuration.config[:domain]}/#{group_id}%40#{group_id}@#{RubyProvisioningApi.configuration.config[:domain]}</id>
			<updated>2012-10-01T05:30:26.474Z</updated>
			<link rel='self' type='application/atom+xml' href='foo link'/>
			<link rel='edit' type='application/atom+xml' href='foo link'/>
			<apps:property name='groupId' value="#{group_id}@#{RubyProvisioningApi.configuration.config[:domain]}"/>
			<apps:property name='groupName' value="#{group_name}"/>
			<apps:property name='emailPermission' value="#{email_permission}"/>
			<apps:property name='permissionPreset' value='Custom'/>
			<apps:property name='description' value="#{description}"/>
		</entry>
		<entry>
			<id>https://apps-apis.google.com/a/feeds/group/2.0/#{RubyProvisioningApi.configuration.config[:domain]}/#{group_id}%40#{group_id}@#{RubyProvisioningApi.configuration.config[:domain]}</id>
			<updated>2012-10-01T05:30:26.474Z</updated>
			<link rel='self' type='application/atom+xml' href='foo link'/>
			<link rel='edit' type='application/atom+xml' href='foo link'/>
			<apps:property name='groupId' value="#{group_id}@#{RubyProvisioningApi.configuration.config[:domain]}"/>
			<apps:property name='groupName' value="#{group_name}"/>
			<apps:property name='emailPermission' value="#{email_permission}"/>
			<apps:property name='permissionPreset' value='Custom'/>
			<apps:property name='description' value="#{description}"/>
		</entry>
    eos

    handle_request(:method => :get,
                   :url => "https://apps-apis.google.com/a/feeds/group/2.0/#{RubyProvisioningApi.configuration.config[:domain]}",
                   :response_body => response_body, :request_body => "")
  end

  def delete_stub(group_id = FAKE_GROUP_ID)
    handle_request(:method => :delete,
                   :url => "https://apps-apis.google.com/a/feeds/group/2.0/#{RubyProvisioningApi.configuration.config[:domain]}/#{group_id}@#{RubyProvisioningApi.configuration.config[:domain]}",
                   :response_body => "", :request_body => "")
  end

  def save_stub(group_id = FAKE_GROUP_ID, group_name = FAKE_GROUP_NAME, description = FAKE_DESCRIPTION, email_permission = FAKE_EMAIL_PERMISSION)
    request_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<atom:entry xmlns:atom=\"http://www.w3.org/2005/Atom\" xmlns:apps=\"http://schemas.google.com/apps/2006\">\n  <atom:category scheme=\"http://schemas.google.com/g/2005#kind\" term=\"http://schemas.google.com/apps/2006#emailList\"/>\n  <apps:property name=\"groupName\" value=\"#{group_name}\"/>\n  <apps:property name=\"description\" value=\"#{description}\"/>\n  <apps:property name=\"emailPermission\" value=\"#{email_permission}\"/>\n</atom:entry>\n"
    handle_request(:method => :post,
                   :url => "https://apps-apis.google.com/a/feeds/group/2.0/#{RubyProvisioningApi.configuration.config[:domain]}",
                   :response_body => "", :request_body => request_body)
  end

  def groups_stub(member_id = FAKE_MEMBER_ID, group_id = FAKE_GROUP_ID, group_name = FAKE_GROUP_NAME, description = FAKE_DESCRIPTION, email_permission = FAKE_EMAIL_PERMISSION)
    response_body = <<-eos
			<?xml version='1.0' encoding='UTF-8'?>
			<feed xmlns='http://www.w3.org/2005/Atom' xmlns:openSearch='http://a9.com/-/spec/opensearchrss/1.0/' xmlns:apps='http://schemas.google.com/apps/2006'>
			<id>foo id</id>
			<updated>foo date</updated>
			<link rel='http://schemas.google.com/g/2005#feed' type='application/atom+xml' href='foo link'/>
			<link rel='http://schemas.google.com/g/2005#post' type='application/atom+xml' href='foo link'/>
			<link rel='self' type='application/atom+xml' href='foo link'/>
			<openSearch:startIndex>1</openSearch:startIndex>
			<entry>
			<id>fake id</id>
			<updated>fake date</updated>
			<link rel='self' type='application/atom+xml' href='foo link'/>
			<link rel='edit' type='application/atom+xml' href='foo link'/>
			<apps:property name='groupId' value="#{group_id}@#{RubyProvisioningApi.configuration.config[:domain]}"/>
			<apps:property name='groupName' value="#{group_name}"/>
			<apps:property name='emailPermission' value="#{email_permission}"/>
			<apps:property name='permissionPreset' value='Custom'/>
			<apps:property name='description' value="#{description}"/>
			<apps:property name='permissionPreset' value='Custom'/>
			<apps:property name='directMember' value='true'/>
			</entry>
			<entry>
			<id>fake id2</id>
			<updated>fake date</updated>
			<link rel='self' type='application/atom+xml' href='foo link'/>
			<link rel='edit' type='application/atom+xml' href='foo link'/>
			<apps:property name='groupId' value="#{group_id}@#{RubyProvisioningApi.configuration.config[:domain]}"/>
			<apps:property name='groupName' value="#{group_name}"/>
			<apps:property name='emailPermission' value="#{email_permission}"/>
			<apps:property name='permissionPreset' value='Custom'/>
			<apps:property name='description' value="#{description}"/>
			<apps:property name='permissionPreset' value='Custom'/>
			<apps:property name='directMember' value='true'/>
			</entry>
			</feed> 
    eos
    handle_request(:method => :get,
                   :url => "https://apps-apis.google.com/a/feeds/group/2.0/#{RubyProvisioningApi.configuration.config[:domain]}/?member=#{member_id}",
                   :response_body => response_body, :request_body => "")
  end

  def add_entity_stub(entity, entity_id, group_id = FAKE_GROUP_ID)
    request_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<atom:entry xmlns:atom=\"http://www.w3.org/2005/Atom\" xmlns:apps=\"http://schemas.google.com/apps/2006\">\n  <atom:category scheme=\"http://schemas.google.com/g/2005#kind\" term=\"http://schemas.google.com/apps/2006#emailList\"/>\n  "

    if entity.eql? "member"
      request_body << "<apps:property name=\"#{entity}Id\" value=\"#{entity_id}\"/>\n</atom:entry>\n"
    else
      request_body << "<apps:property name=\"email\" value=\"#{entity_id}\"/>\n</atom:entry>\n"
    end
    handle_request(:method => :post,
                   :url => "https://apps-apis.google.com/a/feeds/group/2.0/#{RubyProvisioningApi.configuration.config[:domain]}/#{group_id}@#{RubyProvisioningApi.configuration.config[:domain]}/#{entity}",
                   :response_body => "", :request_body => request_body)


  end

  def delete_entity_stub(entity, entity_id, group_id = FAKE_GROUP_ID)
    handle_request(:method => :delete,
                   :url => "https://apps-apis.google.com/a/feeds/group/2.0/#{RubyProvisioningApi.configuration.config[:domain]}/#{group_id}@#{RubyProvisioningApi.configuration.config[:domain]}/#{entity}/#{entity_id}",
                   :response_body => "", :request_body => "")
  end

  def has_entity_stub(entity, entity_id, group_id = FAKE_GROUP_ID)
    handle_request(:method => :get,
                   :url => "https://apps-apis.google.com/a/feeds/group/2.0/#{RubyProvisioningApi.configuration.config[:domain]}/#{group_id}@#{RubyProvisioningApi.configuration.config[:domain]}/#{entity}/#{entity_id}",
                   :response_body => "", :request_body => "")
  end

  #---------------------------------------------------------------------------------------------------------------------

  describe ".find" do

    it "should find an existing group" do
      # define stubs
      find_stub
      # Exec the api call
      group = RubyProvisioningApi::Group.find(FAKE_GROUP_ID)
      # Check values
      group.group_id.should be_eql "#{FAKE_GROUP_ID}@#{RubyProvisioningApi.configuration.config[:domain]}"
      group.group_name.should be_eql FAKE_GROUP_NAME
      group.description.should be_eql FAKE_DESCRIPTION
      group.email_permission.should be_eql FAKE_EMAIL_PERMISSION
    end

    it "should raise an exception if the group does not exist"

  end

  describe ".all" do

    before do
      all_stub
      @groups = RubyProvisioningApi::Group.all
    end

    it "should always return an Array" do
      @groups.should be_kind_of Array
    end

    it "should return an empty array if no Group exists"

    it "should return an array of Group" do
      @groups.each do |group|
        group.should be_kind_of RubyProvisioningApi::Group
      end
    end

    it "should return valid gorups" do
      @groups.each do |group|
        group.group_id.should be_eql "#{FAKE_GROUP_ID}@#{RubyProvisioningApi.configuration.config[:domain]}"
        group.group_name.should be_eql FAKE_GROUP_NAME
        group.description.should be_eql FAKE_DESCRIPTION
        group.email_permission.should be_eql FAKE_EMAIL_PERMISSION
      end

    end

  end

  describe ".delete" do

    it "should delete an existing Group" do
      # define stubs
      find_stub
      delete_stub
      # Exec the api call
      RubyProvisioningApi::Group.find(FAKE_GROUP_ID).delete.should be_eql true
    end

    it "should raise an exception if the given group does not exist"

  end

  describe "#new"

  it "should initialize a group if passing a hash of valid parameters" do
    group = RubyProvisioningApi::Group.new(:group_id => FAKE_GROUP_ID, :group_name => FAKE_GROUP_NAME, :description => FAKE_DESCRIPTION, :email_permission => FAKE_EMAIL_PERMISSION)
    group.group_id.should be_eql FAKE_GROUP_ID
    group.group_name.should be_eql FAKE_GROUP_NAME
    group.description.should be_eql FAKE_DESCRIPTION
    group.email_permission.should be_eql FAKE_EMAIL_PERMISSION
  end

  it "should initialize a group with a step-by-step initialization"


  it "Creates a group" do
    # define stubs
    save_stub
    # Exec the api call
    RubyProvisioningApi::Group.create(:group_id => FAKE_GROUP_NAME, :group_name => FAKE_GROUP_NAME, :description => FAKE_DESCRIPTION, :email_permission => FAKE_EMAIL_PERMISSION)
  end

  it "Saves a group" do
    # define stubs
    save_stub
    # Exec the api call
    RubyProvisioningApi::Group.new(:group_id => FAKE_GROUP_NAME, :group_name => FAKE_GROUP_NAME, :description => FAKE_DESCRIPTION, :email_permission => FAKE_EMAIL_PERMISSION).save
  end

  it "Finds and Updates a group" do
    # constants
    NEW_FAKE_DESCRIPTION = "New Description"
    NEW_FAKE_EMAIL_PERMISSION = "Member"
    NEW_FAKE_GROUP_NAME = "New Name"
    # define stubs
    find_stub
    save_stub(FAKE_GROUP_ID, NEW_FAKE_GROUP_NAME, NEW_FAKE_DESCRIPTION, NEW_FAKE_EMAIL_PERMISSION)
    # Normal update
    group = RubyProvisioningApi::Group.find(FAKE_GROUP_ID)
    group.description = NEW_FAKE_DESCRIPTION
    group.email_permission = NEW_FAKE_EMAIL_PERMISSION
    group.group_name = NEW_FAKE_GROUP_NAME
    group.update
    # With update_attributes
    group = RubyProvisioningApi::Group.find(FAKE_GROUP_ID)
    group.update_attributes(:description => NEW_FAKE_DESCRIPTION, :email_permission => NEW_FAKE_EMAIL_PERMISSION, :group_name => NEW_FAKE_GROUP_NAME)
  end

  it "Returns all groups for a given member" do
    # define constants
    # define stubs
    groups_stub
    groups = RubyProvisioningApi::Group.groups(FAKE_MEMBER_ID)
    groups.each do |group|
      # Check values
      group.group_id.should eql "#{FAKE_GROUP_ID}@#{RubyProvisioningApi.configuration.config[:domain]}"
      group.group_name.should eql FAKE_GROUP_NAME
      group.description.should eql FAKE_DESCRIPTION
      group.email_permission.should eql FAKE_EMAIL_PERMISSION
    end
  end

  it "Adds a member to a group" do
    # define stubs
    find_stub
    find_stub(FAKE_MEMBER_ID)
    add_entity_stub("member", FAKE_MEMBER_ID)
    RubyProvisioningApi::Group.find(FAKE_GROUP_ID).add_member(FAKE_MEMBER_ID)
  end


  it "Checks if a group has a specific member" do
    # define stubs
    find_stub
    has_entity_stub("member", FAKE_MEMBER_ID)
    RubyProvisioningApi::Group.find(FAKE_GROUP_ID).has_member?(FAKE_MEMBER_ID)
  end

  it "Deletes a member" do
    # define stubs
    find_stub
    delete_entity_stub("member", FAKE_MEMBER_ID)
    RubyProvisioningApi::Group.find(FAKE_GROUP_ID).delete_member(FAKE_MEMBER_ID)
  end


  it "Adds an owner to a group" do
    # define stubs
    find_stub
    find_stub(FAKE_OWNER_ID)
    add_entity_stub("owner", FAKE_OWNER_ID)
    RubyProvisioningApi::Group.find(FAKE_GROUP_ID).add_owner(FAKE_OWNER_ID)
  end


  it "Checks if a group has a specific owner" do
    # define stubs
    find_stub
    has_entity_stub("owner", FAKE_OWNER_ID)
    RubyProvisioningApi::Group.find(FAKE_GROUP_ID).has_owner?(FAKE_OWNER_ID)
  end

  it "Deletes an owner" do
    # define stubs
    find_stub
    delete_entity_stub("owner", FAKE_OWNER_ID)
    RubyProvisioningApi::Group.find(FAKE_GROUP_ID).delete_owner(FAKE_OWNER_ID)
  end

end
