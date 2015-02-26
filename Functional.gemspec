# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'functional'
  spec.version       = '0.0.0'
  spec.authors       = ['Tema Bolshakov']
  spec.email         = ['abolshakov@spbtv.com']
  spec.summary       = "%q{Ruby port of some Scala's monads.}"
  spec.description   = "Ruby port of some Scala's monads."
  spec.homepage      = 'https://github.com/bolshakov/functional'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'concurrent-ruby', '~> 0.8'
end
