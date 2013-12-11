# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "amequp/version"

Gem::Specification.new do |s|
  s.name        = "amequp"
  s.version     = Amequp::VERSION
  s.authors     = ["Ben Klang", "Ben Langfeld"]
  s.email       = ["bklang@mojolingo.com", "blangfeld@mojolingo.com"]
  s.homepage    = "https://github.com/bklang/amequp"
  s.summary     = %q{AMQP plugin for Adhearsion}
  s.description = %q{This gem provides a plugin for Adhearsion, allowing you to publish and subscribe to AMQP messages}

  s.license     = 'MIT'

  s.rubyforge_project = "amequp"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_runtime_dependency %q<adhearsion>, ["~> 2.1"]
  s.add_runtime_dependency %q<amqp>, [">= 1.0.0"]

  s.add_development_dependency %q<bundler>, ["~> 1.0"]
  s.add_development_dependency %q<rspec>, ["~> 2.5"]
  s.add_development_dependency %q<rake>, [">= 0"]
  s.add_development_dependency %q<guard-rspec>
 end
