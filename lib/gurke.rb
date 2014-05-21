require 'gurke/version'

#
module Gurke
  require 'gurke/dsl'
  require 'gurke/builder'
  require 'gurke/configuration'
  require 'gurke/runner'
  require 'gurke/steps'
  require 'gurke/step_definition'
  require 'gurke/reporter'

  require 'gurke/feature'
  require 'gurke/background'
  require 'gurke/scenario'
  require 'gurke/step'

  class Error < StandardError; end
  class StepPending < Error; end

  class << self
    #
    # Return path to features directory.
    #
    # @return [Path] Feature directory.
    #
    def root
      @root ||= Path.getwd.join('features')
    end

    # Return configuration object.
    #
    # @return [Configuration] Configuration object.
    #
    def configuration
      @configuration ||= Configuration.new
    end

    # Yield configuration object.
    #
    # @yield [config] Yield configuration object.
    # @yieldparam config [Configuration] Configuration object.
    #
    def configure
      yield configuration if block_given?
    end

    # @api private
    def world
      @world ||= const_set('World', Module.new)
    end
  end
end

::Module.send(:include, Gurke::DSL)
