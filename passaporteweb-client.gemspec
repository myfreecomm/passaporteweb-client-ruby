# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','passaporte_web','version.rb'])

Gem::Specification.new do |spec|
  spec.name          = "passaporteweb-client"
  spec.version       = PassaporteWeb::VERSION
  spec.authors       = ["Rodrigo Tassinari de Oliveira", "Eduardo Hertz", "Rafael B. Tauil"]
  spec.email         = ["rodrigo@pittlandia.net", "rodrigo.tassinari@myfreecomm.com.br", "eduardo.hertz@myfreecomm.com.br", "rafael@tauil.com.br"]
  spec.description   = %q{A Ruby client for the PassaporteWeb REST API}
  spec.summary       = %q{A Ruby client for the PassaporteWeb REST API: https://app.passaporteweb.com.br/static/docs/}
  spec.homepage      = "https://github.com/myfreecomm/passaporteweb-client-ruby"
  spec.license       = "Apache-v2"
  spec.has_rdoc      = true

  # VCR cassettes are too long for the gemspec, see http://stackoverflow.com/questions/14371686/building-rails-3-engine-throwing-gempackagetoolongfilename-error
  # spec.files         = `git ls-files`.split($/)
  spec.files         = `git ls-files`.split($/).reject { |f| f =~ %r{(vcr_cassettes)/} }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client", "~> 1.8.0"
  spec.add_dependency "multi_json", "~> 1.11"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rdoc", "~> 5.1"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "vcr", "~> 2.4"
  spec.add_development_dependency "webmock", "~> 1.9.3"
  spec.add_development_dependency "pry-byebug", "~> 3.4"
  spec.add_development_dependency "awesome_print", "~> 1.8"
  spec.add_development_dependency "simplecov", "~> 0.14"
  spec.add_development_dependency "coveralls", "~> 0.8"
  spec.add_development_dependency "json", "~> 2.1"
end
