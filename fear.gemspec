# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "fear/version"
Gem::Specification.new do |spec|
  spec.name = "fear"
  spec.version = Fear::VERSION
  spec.authors = ["Tëma Bolshakov"]
  spec.email = ["tema@bolshakov.dev"]
  spec.summary = "%q{Ruby port of some Scala's monads.}"
  spec.description = "Ruby port of some Scala's monads."
  spec.homepage = "https://github.com/bolshakov/fear"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin\/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^spec\/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1")
end
