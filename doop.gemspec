# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'doop/version'

Gem::Specification.new do |spec|
  spec.name          = "doop"
  spec.version       = Doop::VERSION
  spec.authors       = ["Mark Middleton"]
  spec.email         = ["markymiddleton@gmail.com"]
  spec.summary       = %q{Question framework for govuk websites.}
  spec.description   = %q{A question framework for govuk sites, inspired by the work GDS have done to standardize the cross government internet presence.}
  spec.homepage      = "https://github.com/coder36/doop"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "app"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"

  spec.add_runtime_dependency "rails", ">= 4.1"
end

