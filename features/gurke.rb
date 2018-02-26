# frozen_string_literal: true

require 'gurke/rspec'
require 'tmpdir'

Gurke.configure do |c|
  c.around(:scenario) do |scenario|
    Dir.mktmpdir('gurke') do |dir|
      @__root = Pathname.new(dir)
      scenario.call
    end
  end
end
