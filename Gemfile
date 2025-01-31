# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in gurke-formatters-headless.gemspec
gemspec

gem 'rake'
gem 'rake-release'

group :development, :test do
  gem 'pry'
  gem 'rubocop-config', github: 'jgraichen/rubocop-config', ref: '9f3e5cd0e519811a7f615f265fca81a4f4e843b9'
end

group :test do
  gem 'rspec', '~> 3.9'
  gem 'test-unit'

  gem 'simplecov', require: false
  gem 'simplecov-cobertura', require: false
end
