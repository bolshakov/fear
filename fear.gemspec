lib = File.expand_path('lib', __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fear/version'
Gem::Specification.new do |spec|
  spec.name          = 'fear'
  spec.version       = Fear::VERSION
  spec.authors       = ['Tema Bolshakov']
  spec.email         = ['abolshakov@spbtv.com']
  spec.summary       = "%q{Ruby port of some Scala's monads.}"
  spec.description   = "Ruby port of some Scala's monads."
  spec.homepage      = 'https://github.com/bolshakov/fear'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin\/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec\/})
  spec.require_paths = ['lib']

  spec.post_install_message = <<-MSG
    Fear v0.11.0 introduces backwards-incompatible changes.
    Please see https://github.com/bolshakov/fear/blob/master/CHANGELOG.md#0110 for details.
    Successfully installed fear-#{Fear::VERSION}
  MSG

  spec.add_runtime_dependency 'dry-equalizer', '<= 0.2.1'
  spec.add_runtime_dependency 'dry-struct'
  spec.add_runtime_dependency 'treetop'

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'benchmark-ips'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'dry-matcher'
  spec.add_development_dependency 'qo'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'rubocop', '0.65.0'
  spec.add_development_dependency 'rubocop-rspec', '1.32.0'
  spec.add_development_dependency 'yard'
end
