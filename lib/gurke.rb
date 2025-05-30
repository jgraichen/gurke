# frozen_string_literal: true

require 'gurke/version'
require 'pathname'

module Gurke
  require 'gurke/feature'
  require 'gurke/background'
  require 'gurke/scenario'
  require 'gurke/step'
  require 'gurke/tag'

  require 'gurke/run_list'
  require 'gurke/feature_list'

  require 'gurke/dsl'
  require 'gurke/builder'
  require 'gurke/configuration'
  require 'gurke/runner'
  require 'gurke/steps'
  require 'gurke/step_definition'
  require 'gurke/reporter'
  require 'gurke/world'

  module Reporters
    require 'gurke/reporters/colored'

    require 'gurke/reporters/null_reporter'
    require 'gurke/reporters/compact_reporter'
    require 'gurke/reporters/default_reporter'
    require 'gurke/reporters/team_city_reporter'
  end

  class Error < StandardError; end
  class StepPending < Error; end
  class StepAmbiguous < Error; end

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
      @world ||= World
    end
  end
end

Module.include Gurke::DSL
