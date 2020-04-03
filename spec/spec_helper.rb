# frozen_string_literal: true

require 'rspec'
require 'simplecov'
SimpleCov.start

if ENV['CI']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'gurke'

Dir[File.expand_path('spec/support/**/*.rb')].sort.each {|f| require f }

module Helper
  def unindent(str)
    str.rstrip.gsub(/^\./, '')
  end
end

RSpec.configure do |config|
  config.order = 'random'
  config.include Helper
end
