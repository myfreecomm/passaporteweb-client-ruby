# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'passaporte_web/version'

Gem::Specification.new do |spec|
  spec.name          = "passaporteweb-client"
  spec.version       = PassaporteWeb::VERSION
  spec.authors       = ["Rodrigo Tassinari de Oliveira"]
  spec.email         = ["rodrigo@pittlandia.net", "rodrigo.tassinari@myfreecomm.com.br"]
  spec.description   = %q{A Ruby client for the PassaporteWeb REST API}
  spec.summary       = %q{A Ruby client for the PassaporteWeb REST API: https://app.passaporteweb.com.br/static/docs/}
  spec.homepage      = "https://github.com/myfreecomm/passaporteweb-client-ruby"
  spec.license       = "Apache-v2"
  spec.has_rdoc      = true

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client", "~> 1.6"
  spec.add_dependency "multi_json", "~> 1.7"
  spec.add_dependency "recursive-open-struct", "~> 0.3"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.13"
  spec.add_development_dependency "vcr", "~> 2.4"
  spec.add_development_dependency "webmock", "~> 1.10"
  spec.add_development_dependency "pry", "~> 0.9"
  spec.add_development_dependency "pry-nav", "~> 0.2"
  spec.add_development_dependency "awesome_print", "~> 1.1"
  # spec.add_development_dependency "simplecov", "~> 0.7"
  spec.add_development_dependency "coveralls", "~> 0.6"
end
