require 'rubygems'
require 'spork'
require 'faker'
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

RSpec.configure do |config|
  # some (optional) config here
end
