# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'backstop-dimensioned/version'

Gem::Specification.new do |gem|
  gem.name          = "backstop-dimensioned"
  gem.version       = Backstop::Dimensioned::VERSION
  gem.authors       = ["Michael Hale"]
  gem.email         = ["mike@hales.ws"]
  gem.description   = "An extension to backstop that handles custom data with dimensions"
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/mikehale/backstop-dimensioned'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_development_dependency('rack-test')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('webmock')
  gem.add_dependency('rest-client')
  gem.add_dependency('scrolls')
  gem.add_dependency('sinatra')
end
