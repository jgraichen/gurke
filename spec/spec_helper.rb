if ENV['CI'] || (defined?(:RUBY_ENGINE) && RUBY_ENGINE != 'rbx')
  require 'coveralls'
  Coveralls.wear! do
    add_filter 'spec'
  end
end

require 'bundler'
Bundler.require

require 'gurke'

Dir[File.expand_path('spec/support/**/*.rb')].each{|f| require f }

RSpec.configure do |config|
  config.order = 'random'
end