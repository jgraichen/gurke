# frozen_string_literal: true

if ENV['CI'] || (defined?(:RUBY_ENGINE) && RUBY_ENGINE != 'rbx')
  require 'coveralls'
  Coveralls.wear! do
    add_filter 'spec'
  end
end

require 'bundler'
Bundler.require

require 'gurke'

Dir[File.expand_path('spec/support/**/*.rb')].each {|f| require f }

module Helper
  def unindent(str)
    str.rstrip.gsub(/^\./, '')
  end
end

RSpec.configure do |config|
  config.order = 'random'
  config.include Helper
end
