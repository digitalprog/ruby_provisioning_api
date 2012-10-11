require 'rubygems'
require 'spork'
require 'faker'
require 'vcr'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
end

Spork.each_run do
  # This code will be run each time you run your specs.
end

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'ruby_provisioning_api'

VCR.configure do |c|
  c.cassette_library_dir = File.join(File.dirname(__FILE__), "ruby_provisioning_api", "vcr")
  c.hook_into :webmock
  c.filter_sensitive_data('<USERNAME>') { RubyProvisioningApi.configuration.config[:username] }
  c.filter_sensitive_data('<PASSWORD>') { RubyProvisioningApi.configuration.config[:password] }
  c.filter_sensitive_data('<LOCATION>') { RubyProvisioningApi.configuration.config[:domain] }
end


RSpec.configure do |config|
  # some (optional) config here
end