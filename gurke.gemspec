# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gurke/version'

Gem::Specification.new do |spec|
  spec.name          = 'gurke'
  spec.version       = Gurke::VERSION
  spec.authors       = ['Jan Graichen']
  spec.email         = %w[jgraichen@altimos.de]
  spec.homepage      = 'https://github.com/jgraichen/gurke'
  spec.license       = 'MIT'

  spec.summary =
    'An alternative gherkin feature runner inspired by rspec and turnip.'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 2.7.0'

  spec.files = Dir['**/*'].grep %r{^(
    (bin/|lib/|test/|spec/|features/)|
    (\w*\.gemspec|LICENSE.*|README.*|CHANGELOG.*)$
  )}x

  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency 'colorize'
  spec.add_dependency 'gherkin', '~> 2.0'
  spec.add_dependency 'optimist', '~> 3.0'
end
