# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spreadsheet_reader/row/version'

Gem::Specification.new do |spec|
  spec.name          = 'spreadsheet_reader'
  spec.version       = SpreadsheetReader::VERSION
  spec.authors       = ['muzk']
  spec.email         = ['ngomez@hasu.cl']
  spec.description   = 'Provides an easy way to add model-based validations to excel files.'
  spec.summary       = 'Provides an easy way to add model-based validations to excel files.'
  spec.homepage      = 'https://github.com/muZk/spreadsheet-reader'
  spec.license       ='MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.3.2'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'factory_girl', '~> 4.4.0'

  spec.add_runtime_dependency 'roo', '~> 1.13.2'
  spec.add_runtime_dependency 'activemodel', '~> 4.1.0'
  spec.add_runtime_dependency 'activerecord', '~> 4.1.0'
end
