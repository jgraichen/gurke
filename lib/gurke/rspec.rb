# frozen_string_literal: true

require 'rspec/expectations'

Gurke.configure do |c|
  c.include RSpec::Matchers
end
