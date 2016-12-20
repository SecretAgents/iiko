# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iiko/version'

Gem::Specification.new do |spec|
  spec.name          = 'iiko'
  spec.version       = Iiko::VERSION
  spec.authors       = ['Alabama Air']
  spec.email         = ['alabama.air@gmail.com']

  spec.summary       = 'Integration with API iiko.ru'
  spec.description   = 'Description'
  spec.homepage      = 'https://github.com/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.add_development_dependency "httparty"
end
