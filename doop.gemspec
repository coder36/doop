# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'doop/version'
require 'fileutils'

# Copy files for rails doopgovuk template:
if !Dir['doop_demo/*'].empty?
  dest = "lib/generators/doopgovuk/templates"
  FileUtils.cp "doop_demo/app/assets/stylesheets/demo.css.scss", "#{dest}/app/assets/stylesheets/demo.css.scss"
  FileUtils.cp "doop_demo/app/assets/javascripts/demo.js.coffee", "#{dest}/app/assets/javascripts/demo.js.coffee"
  FileUtils.cp "doop_demo/app/controllers/demo_controller.rb", "#{dest}/app/controllers/demo_controller.rb"
  FileUtils.cp "doop_demo/app/views/layouts/application.html.erb", "#{dest}/app/views/layouts/application.html.erb"
  FileUtils.cp_r "doop_demo/app/views/doop", "#{dest}/app/views"
  FileUtils.cp_r "doop_demo/app/views/demo", "#{dest}/app/views"
  FileUtils.cp_r "doop_demo/spec", "#{dest}"
end

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

  spec.add_runtime_dependency "rails", "~> 4.1"
end

