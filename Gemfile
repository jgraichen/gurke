# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in gurke-formatters-headless.gemspec
gemspec

gem 'my-rubocop', github: 'jgraichen/my-rubocop'
gem 'rspec', '~> 3.9'

group :test do
  gem 'codecov', require: false
end

group :development do
  gem 'pry'
  gem 'pry-nav'

  gem 'redcarpet', platform: :ruby
  gem 'yard'
end
