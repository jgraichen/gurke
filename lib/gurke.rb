require 'cucumber'

require 'gurke/patch/cucumber_cli_configuration'
require 'gurke/formatter'

require 'gurke/current'
require 'gurke/hooks'


module Gurke
  class << self
    def current
      @current ||= Gurke::Current.instance
    end

    def before(stage, &block)
      Hooks.before.add stage, &block
    end

    def after(stage, &block)
      Hooks.after.add stage, &block
    end

    def step!(opts = {})
      if (fmt = Gurke::Formatter.instance)
        fmt.manual_step current.step, opts
      end
    end
  end
end
