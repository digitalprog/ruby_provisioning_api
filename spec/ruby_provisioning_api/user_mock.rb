require 'webmock'

class UserMock

  attr_accessor :user_list

  def initialize
    @user_list = []
    @domain = RubyProvisioningApi.configuration.config[:domain]
    stub_login
  end

  def stub_login
    xml_body = <<-eos
    SID=DQAAAOUAAACA_vaRWNvKij2fLLgRRU10BO79pFK1H_TCStyIyTyQ7Q04BzsoWM2ggTaC6VPRcSw1ZxF86ZZ0Nkg4Cbd2u7m1kmSPEUC88jtzqIa4Vk1NqNpn5VzKmsBb3wXRUJjClPsn6t8SfHNhzmZE-DwzIbBK37oSW3rtPxhZjVhBNUtXTLeoxaRFUaw08_MqrLbIsM2Xa049lW1HhSUiVTINwW3qireKimvQe_Sl6Vs7uYYx8MI_nLOn-SX_iE65b41_L3RWuKkapTCS5nucqqcJRNapZ-3Qx8OaDBisg0Yz4rNKsXmuO5CTkaEjXWkRM0VsFUU
		LSID=DQAAAOcAAABAo1sgz1Cn_INiScJcbGwIoK5mAYMoOEOiIl_I3q4ei1KngWGQB_gNub471pCPo6zbkB72nlDMvhYYJTUqwx7gyyxQA0qvrDSBaTh4J8y0HF5eFrbFqc17D97AiqkZjedK2msrWV9b3M7ObEqhML3Ewmw845ZXaAgAz8m_dS2-5FEBAazm5x-yMTDYx-rVlpdAVDjPX5OG39MwWVLJv-q54NDBMPIvwl4th16-near-Ta6KrBotmwO7xSYOI_X84HyQlB1jwGei8kVnNZ8B5qenjli8WPJ-fGr9tXTDFXHJzsm1wUpsZN8Sv-LZKYUKkA
		Auth=DQAAAOYAAABAo1sgz1Cn_INiScJcbGwIoK5mAYMoOEOiIl_I3q4ei1KngWGQB_gNub471pCPo6xLpX3vI4aeREw7UkLDNza6qIalwH2MRBmxFeFCfXIoxXYj8FcP262Vf6V59EDPKUls3iYXnHtBCqhRo1KMkvehe242uvNN5figfS6s_hsKbB0eSP3on6kB31JyHJB4VVN72woDX2xsjPA5izqJfbTAlm3EUQsQGOqO_mnhXpD5sk5qTSxhfirm3ffz3PTRS0OVFaiydOVwzpHXZHB2DBbizRJLiGGDL4JP7Ea-E4i_nEbQTLmoqAV0WtOAsfOLMgs
    eos
    WebMock.stub_request(:post, "https://www.google.com/accounts/ClientLogin").
        with(:body => {:Email => "#{RubyProvisioningApi.configuration.config[:username]}@#{RubyProvisioningApi.configuration.config[:domain]}",
                       :Passwd => RubyProvisioningApi.configuration.config[:password], :accountType => "HOSTED", :service => "apps"},
             :headers => {'Accept' => '*/*', 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby'}).
        to_return(:status => 200,
                  :body => xml_body,
                  :headers => {})
    @token = RubyProvisioningApi.connection.token
  end

  def stub_find(username)
    user = find_user(username)
    if user
      xml_response = <<-eos
      <?xml version='1.0' encoding='UTF-8'?>
      <entry xmlns='http://www.w3.org/2005/Atom' xmlns:apps='http://schemas.google.com/apps/2006' xmlns:gd='http://schemas.google.com/g/2005'>
        <id>https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0/#{user.user_name}</id>
        <updated>1970-01-01T00:00:00.000Z</updated>
        <category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/apps/2006#user'/>
        <title type='text'>#{user.user_name}</title>
        <link rel='self' type='application/atom+xml' href='https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0/#{user.user_name}'/>
        <link rel='edit' type='application/atom+xml' href='https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0/#{user.user_name}'/>
        <apps:login userName='#{user.user_name}' suspended='#{user.suspended}' ipWhitelisted='false' admin='true' changePasswordAtNextLogin='false' agreedToTerms='true'/>
        <apps:quota limit='#{user.quota}'/><apps:name familyName='#{user.family_name}' givenName='#{user.given_name}'/>
        <gd:feedLink rel='http://schemas.google.com/apps/2006#user.nicknames' href='https://apps-apis.google.com/a/feeds/#{@domain}/nickname/2.0?username=#{user.user_name}'/>
        <gd:feedLink rel='http://schemas.google.com/apps/2006#user.emailLists' href='https://apps-apis.google.com/a/feeds/#{@domain}/emailList/2.0?recipient=#{user.user_name}%40#{@domain}'/>
      </entry>
      eos
      status = 200
    else
      xml_response = <<-eos
      <?xml version="1.0" encoding="UTF-8"?>
        <AppsForYourDomainErrors>
        <error errorCode="1301" invalidInput="#{username}" reason="EntityDoesNotExist" />
      </AppsForYourDomainErrors>
      eos
      status = 400
    end
    WebMock.stub_request(:get, "https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0/#{username}").
        with(:headers => {'Accept' => '*/*', 'Authorization' => "GoogleLogin auth=#{@token}", 'Content-Type' => 'application/atom+xml', 'User-Agent' => 'Ruby'}).
        to_return(:status => status,
                  :body => xml_response,
                  :headers => {})
  end

  def stub_all
    xml_response = <<-eos
    <?xml version='1.0' encoding='UTF-8'?>
    <feed xmlns='http://www.w3.org/2005/Atom' xmlns:openSearch='http://a9.com/-/spec/opensearchrss/1.0/' xmlns:apps='http://schemas.google.com/apps/2006' xmlns:gd='http://schemas.google.com/g/2005'>
      <id>https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0</id>
      <updated>1970-01-01T00:00:00.000Z</updated>
      <category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/apps/2006#user'/>
      <title type='text'>Users</title>
      <link rel='http://schemas.google.com/g/2005#feed' type='application/atom+xml' href='https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0'/>
      <link rel='http://schemas.google.com/g/2005#post' type='application/atom+xml' href='https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0'/>
      <link rel='self' type='application/atom+xml' href='https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0'/>
      <openSearch:startIndex>1</openSearch:startIndex>
    eos
    @user_list.each do |user|
      user_xml = <<-eos
      <entry>
        <id>https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0/#{user.user_name}</id>
        <updated>1970-01-01T00:00:00.000Z</updated>
        <category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/apps/2006#user'/>
        <title type='text'>#{user.user_name}</title>
        <link rel='self' type='application/atom+xml' href='https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0/#{user.user_name}'/>
        <link rel='edit' type='application/atom+xml' href='https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0/#{user.user_name}'/>
        <apps:login userName='#{user.user_name}' suspended='#{user.suspended}' ipWhitelisted='false' admin='false' changePasswordAtNextLogin='false' agreedToTerms='false'/>
        <apps:quota limit='#{user.quota}'/>
        <apps:name familyName='#{user.family_name}' givenName='#{user.given_name}'/>
        <gd:feedLink rel='http://schemas.google.com/apps/2006#user.nicknames' href='https://apps-apis.google.com/a/feeds/#{@domain}/nickname/2.0?username=#{user.user_name}'/>
        <gd:feedLink rel='http://schemas.google.com/apps/2006#user.emailLists' href='https://apps-apis.google.com/a/feeds/#{@domain}/emailList/2.0?recipient=#{user.user_name}%40#{@domain}'/>
      </entry>
      eos
      xml_response << user_xml
    end
    WebMock.stub_request(:get, "https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0").
        with(:headers => {'Accept' => '*/*', 'Authorization' => "GoogleLogin auth=#{@token}", 'Content-Type' => 'application/atom+xml', 'User-Agent' => 'Ruby'}).
        to_return(:status => 200,
                  :body => xml_response,
                  :headers => {})
  end

  def stub_save(user)
    xml_request = <<-eof
    <?xml version='1.0' encoding='UTF-8'?>
    <entry xmlns='http://www.w3.org/2005/Atom' xmlns:apps='http://schemas.google.com/apps/2006' xmlns:gd='http://schemas.google.com/g/2005'>
      <id>https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0/#{user.user_name}</id>
      <updated>1970-01-01T00:00:00.000Z</updated>
      <category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/apps/2006#user'/>
      <title type='text'>#{user.user_name}</title>
      <link rel='self' type='application/atom+xml' href='https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0/#{user.user_name}'/>
      <link rel='edit' type='application/atom+xml' href='https://apps-apis.google.com/a/feeds/#{@domain}/user/2.0/#{user.user_name}'/>
      <apps:login userName='#{user.user_name}' suspended='#{user.suspended}' ipWhitelisted='false' admin='false' changePasswordAtNextLogin='false' agreedToTerms='false'/>
      <apps:quota limit='#{user.quota}'/>
      <apps:name familyName='#{user.family_name}' givenName='#{user.given_name}'/>
      <gd:feedLink rel='http://schemas.google.com/apps/2006#user.nicknames' href='https://apps-apis.google.com/a/feeds/#{@domain}/nickname/2.0?username=#{user.user_name}'/>
      <gd:feedLink rel='http://schemas.google.com/apps/2006#user.emailLists' href='https://apps-apis.google.com/a/feeds/#{@domain}/emailList/2.0?recipient=#{user.user_name}%40#{@domain}'/>
    </entry>
    eof
  end

  private

  def find_user(username)
    index = @user_list.index { |u| u.user_name == username }
    index ? @user_list[index] : nil
  end

end