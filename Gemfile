# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in gurke-formatters-headless.gemspec
gemspec

gem 'rspec', '~> 3.9'
gem 'rubocop-config', github: 'jgraichen/rubocop-config', ref: 'v7'

group :test do
  gem 'codecov', require: false
  gem 'test-unit'
end

group :development do
  gem 'pry'
  gem 'pry-nav'

  gem 'redcarpet', platform: :ruby
  gem 'yard'
end
