# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gurke/version'

Gem::Specification.new do |spec|
  spec.name          = 'gurke'
  spec.version       = Gurke::VERSION
  spec.authors       = ['Jan Graichen']
  spec.email         = %w(jg@altimos.de)
  spec.description   = %q{An alternative gherkin feature runner inspired by rspec and turnip.}
  spec.summary       = %q{An alternative gherkin feature runner inspired by rspec and turnip.}
  spec.homepage      = 'https://github.com/jgraichen/gurke'
  spec.license       = 'MIT'

  spec.files         = Dir['**/*'].grep(%r{^((bin|lib|test|spec|features)/|.*\.gemspec|.*LICENSE.*|.*README.*|.*CHANGELOG.*)})
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency 'trollop'
  spec.add_dependency 'gherkin'
  spec.add_dependency 'colorize'

  spec.add_development_dependency 'bundler', '~> 1.3'

  # Append travis build number for auto-releases
  spec.version = "#{spec.version}.1.b#{ENV['TRAVIS_BUILD_NUMBER']}" if ENV['TRAVIS_BUILD_NUMBER']
end
