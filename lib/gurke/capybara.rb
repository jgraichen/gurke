require 'capybara'
require 'gurke'
require 'capybara/dsl'
require 'capybara/rspec/matchers'

Gurke.configure do |c|
  c.include Capybara::DSL, type: :feature
  c.include Capybara::RSpecMatchers, type: :feature

  c.before do
    next unless self.class.include?(Capybara::DSL)

    if context.metadata[:js]
      Capybara.current_driver = Capybara.javascript_driver
    end

    if context.metadata[:driver]
      Capybara.current_driver = context.metadata[:driver]
    end
  end

  c.after do
    next unless self.class.include?(Capybara::DSL)

    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
