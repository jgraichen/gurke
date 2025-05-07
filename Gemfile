# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in gurke-formatters-headless.gemspec
gemspec

gem 'rake'
gem 'rake-release'

group :development, :test do
  gem 'pry'
  gem 'rubocop-config', github: 'jgraichen/rubocop-config', tag: 'v14'
end

group :test do
  gem 'rspec', '~> 3.9'
  gem 'test-unit'

  gem 'simplecov', require: false
  gem 'simplecov-cobertura', require: false
end
