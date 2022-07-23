# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "fear/version"
Gem::Specification.new do |spec|
  spec.name = "fear"
  spec.version = Fear::VERSION
  spec.authors = ["Tema Bolshakov"]
  spec.email = ["abolshakov@spbtv.com"]
  spec.summary = "%q{Ruby port of some Scala's monads.}"
  spec.description = "Ruby port of some Scala's monads."
  spec.homepage = "https://github.com/bolshakov/fear"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin\/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^spec\/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.add_development_dependency "benchmark-ips"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "concurrent-ruby"
  spec.add_development_dependency "dry-matcher"
  spec.add_development_dependency "dry-monads"
  spec.add_development_dependency "qo"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "rubocop-rspec", "1.34.0"
  spec.add_development_dependency "rubocop", "1.32.0"
  spec.add_development_dependency "ruby_coding_standard"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "dry-types"
  spec.add_development_dependency "fear-rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-lcov"
end
