# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'justiz/version'

Gem::Specification.new do |spec|
  spec.name          = "justiz"
  spec.version       = Justiz::VERSION
  spec.authors       = ["Mike Park"]
  spec.email         = ["mikep@quake.net"]
  spec.description   = %q{Extracts contact data.}
  spec.summary       = %q{Extract contact data from http://www.justizadressen.nrw.de/}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = ['justiz']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mechanize"
  spec.add_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.6"
  spec.add_development_dependency "awesome_print"
end
