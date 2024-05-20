# frozen_string_literal: true

require 'rspec'
require 'simplecov'
require 'simplecov-cobertura'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::CoberturaFormatter,
])
SimpleCov.start

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

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
  end
end
