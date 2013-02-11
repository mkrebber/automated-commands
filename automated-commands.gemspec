# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'automated_commands/version'

Gem::Specification.new do |gem|
  gem.name          = "automated-commands"
  gem.version       = AutomatedCommands::VERSION
  gem.authors       = ["Raphael Randschau"]
  gem.email         = ["nicolai86@me.com"]
  gem.description   = %q{Insanely fast TestUnit tests using Rails & Commands}
  gem.summary       = %q{Insanely fast TestUnit tests using Rails & Commands}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'listen', '~> 0.7.2'
  gem.add_dependency 'commands', '~> 0.2.1'
  gem.add_development_dependency 'rake', '~> 10.0.3'
end
