require 'gurke/version'

#
module Gurke
  require 'gurke/feature'
  require 'gurke/background'
  require 'gurke/scenario'
  require 'gurke/step'
  require 'gurke/tag'

  require 'gurke/dsl'
  require 'gurke/builder'
  require 'gurke/configuration'
  require 'gurke/runner'
  require 'gurke/steps'
  require 'gurke/step_definition'
  require 'gurke/reporter'

  class Error < StandardError; end
  class StepPending < Error; end

  class << self
    #
    # Return path to features directory.
    #
    # @return [Path] Feature directory.
    #
    def root
      @root ||= Pathname.new(Dir.getwd).join('features')
    end

    # Return configuration object.
    #
    # @return [Configuration] Configuration object.
    #
    def config
      @config ||= Configuration.new
    end

    # Yield configuration object.
    #
    # @yield [config] Yield configuration object.
    # @yieldparam config [Configuration] Configuration object.
    #
    def configure
      yield config if block_given?
    end

    # @api private
    def world
      @world ||= const_set('World', Module.new)
    end
  end
end

::Module.send(:include, Gurke::DSL)
