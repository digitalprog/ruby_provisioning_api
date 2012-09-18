# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ruby_provisioning_api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Davide Targa", "Damiano Braga"]
  gem.email         = ["davide.targa@gmail.com", "damiano.braga@gmail.com"]
  gem.description   = %q{a ruby wrapper for google provisioning api}
  gem.summary       = %q{a ruby wrapper for google provisioning api}
  gem.homepage      = "https://github.com/digitalprog/ruby_provisioning_api"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ruby_provisioning_api"
  gem.require_paths = ["lib"]
  gem.version       = RubyProvisioningApi::VERSION
  gem.add_dependency 'faraday'
end
