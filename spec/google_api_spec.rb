require 'spec_helper'
require 'webmock/rspec'
require 'ruby_provisioning_api'

describe "Group" do

	before :all do
    RubyProvisioningApi.configure do |config|
      config.config_file = File.expand_path(File.join(__FILE__, "..", "..", "lib", "ruby_provisioning_api", "config", "google_apps.yml"))
    end
    # Fake authentication XML body
    xml_body = "SID=DQAAAOUAAACA_vaRWNvKij2fLLgRRU10BO79pFK1H_TCStyIyTyQ7Q04BzsoWM2ggTaC6VPRcSw1ZxF86ZZ0Nkg4Cbd2u7m1kmSPEUC88jtzqIa4Vk1NqNpn5VzKmsBb3wXRUJjClPsn6t8SfHNhzmZE-DwzIbBK37oSW3rtPxhZjVhBNUtXTLeoxaRFUaw08_MqrLbIsM2Xa049lW1HhSUiVTINwW3qireKimvQe_Sl6Vs7uYYx8MI_nLOn-SX_iE65b41_L3RWuKkapTCS5nucqqcJRNapZ-3Qx8OaDBisg0Yz4rNKsXmuO5CTkaEjXWkRM0VsFUU
		LSID=DQAAAOcAAABAo1sgz1Cn_INiScJcbGwIoK5mAYMoOEOiIl_I3q4ei1KngWGQB_gNub471pCPo6zbkB72nlDMvhYYJTUqwx7gyyxQA0qvrDSBaTh4J8y0HF5eFrbFqc17D97AiqkZjedK2msrWV9b3M7ObEqhML3Ewmw845ZXaAgAz8m_dS2-5FEBAazm5x-yMTDYx-rVlpdAVDjPX5OG39MwWVLJv-q54NDBMPIvwl4th16-near-Ta6KrBotmwO7xSYOI_X84HyQlB1jwGei8kVnNZ8B5qenjli8WPJ-fGr9tXTDFXHJzsm1wUpsZN8Sv-LZKYUKkA
		Auth=DQAAAOYAAABAo1sgz1Cn_INiScJcbGwIoK5mAYMoOEOiIl_I3q4ei1KngWGQB_gNub471pCPo6xLpX3vI4aeREw7UkLDNza6qIalwH2MRBmxFeFCfXIoxXYj8FcP262Vf6V59EDPKUls3iYXnHtBCqhRo1KMkvehe242uvNN5figfS6s_hsKbB0eSP3on6kB31JyHJB4VVN72woDX2xsjPA5izqJfbTAlm3EUQsQGOqO_mnhXpD5sk5qTSxhfirm3ffz3PTRS0OVFaiydOVwzpHXZHB2DBbizRJLiGGDL4JP7Ea-E4i_nEbQTLmoqAV0WtOAsfOLMgs"

    stub_request(:post, "https://www.google.com/accounts/ClientLogin").
    with(:body => {:Email => "#{RubyProvisioningApi.configuration.config[:username]}@#{RubyProvisioningApi.configuration.config[:domain]}", :Passwd => RubyProvisioningApi.configuration.config[:password], :accountType =>  "HOSTED", :service => "apps"},:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => xml_body, :headers => {})
    @token = RubyProvisioningApi::Connection.new.token

	end

	it "Finds a group" do
		# Fake XML response body
		xml_body = <<-eos
		<?xml version='1.0' encoding='UTF-8'?>
		<entry xmlns='http://www.w3.org/2005/Atom' xmlns:apps='http://schemas.google.com/apps/2006'>
		<id>foo bar</id>
		<updated>foo bar date</updated>
		<link rel='self' type='application/atom+xml' href='foo link'/>
		<link rel='edit' type='application/atom+xml' href='foo link'/>
		<apps:property name='groupId' value="foo@#{RubyProvisioningApi.configuration.config[:domain]}"/><apps:property name='groupName' value='foo bar'/>
		<apps:property name='emailPermission' value='Owner'/><apps:property name='permissionPreset' value='Custom'/>
		<apps:property name='description' value='foo description'/></entry>
		eos

		stub_request(:get, "https://apps-apis.google.com/a/feeds/group/2.0/#{RubyProvisioningApi.configuration.config[:domain]}/foo").
			with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>"GoogleLogin auth=#{@token}", 'Content-Type'=>'application/atom+xml', 'User-Agent'=>'Ruby'}).
			to_return(:status => 200, :body => xml_body, :headers => {})
		RubyProvisioningApi::Group.find("foo")
	end
	
end
