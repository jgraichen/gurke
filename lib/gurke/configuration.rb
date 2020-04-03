# frozen_string_literal: true

require 'forwardable'

module Gurke
  class Configuration
    # @api private
    def initialize
      @default_retries = 0
      @flaky_retries = 1
    end

    #
    # How often a scenario is retries on failure by default.
    #
    # Defaults to none (0).
    #
    attr_accessor :default_retries

    # How often a scenario marked as flaky is retries.
    #
    # Defaults to one (1).
    #
    attr_accessor :flaky_retries

    # Define a before filter running before given action.
    #
    # @example
    #   Gurke.before(:step) do
    #     puts step.description
    #   end
    #
    # @param action [Symbol] A defined action like `:feature`,
    #   `:scenario` or `:step`.
    #
    # @yield Before any matching action is executed.
    #
    def before(action = :scenario, opts = nil, &block)
      raise ArgumentError.new "Unknown hook: #{action}" unless hooks[action]

      hooks[action].append :before, Hook.new(opts, &block)
    end

    def around(action = :scenario, opts = nil, &block)
      raise ArgumentError.new "Unknown hook: #{action}" unless hooks[action]

      hooks[action].append :around, Hook.new(opts, &block)
    end

    # Define a after filter running after given action.
    #
    # @example
    #   Gurke.after(:step) do
    #     puts step.description
    #   end
    #
    # @param action [Symbol] A defined action like `:feature`,
    #   `:scenario` or `:step`.
    #
    # @yield After any matching action is executed.
    #
    def after(action = :scenario, opts = nil, &block)
      raise ArgumentError.new "Unknown hook: #{action}" unless hooks[action]

      hooks[action].append :after, Hook.new(opts, &block)
    end

    # Include given module into all or specific features or
    # scenarios.
    #
    # @example
    #   Gurke.include(MyTestMethods)
    #
    # @param mod [Module] Module to include.
    # @param opts [Hash] Options.
    #
    def include(mod, opts = {})
      inclusions << Inclusion.new(mod, opts)
    end

    # @api private
    def inclusions
      @inclusions ||= []
    end

    # @api private
    def hooks
      @hooks ||= begin
        hooks = {
          features: HookSet.new,
          feature: HookSet.new,
          scenario: HookSet.new,
          step: HookSet.new,
          system: HookSet.new
        }

        hooks[:each] = hooks[:scenario]
        hooks
      end
    end

    # @api private
    class Inclusion
      attr_reader :mod, :opts

      def initialize(mod, opts)
        @mod  = mod
        @opts = opts
      end

      def tags
        @tags ||= begin
          tags = opts.fetch(:tags, [])
          tags = [tags] unless tags.is_a?(Array)
          tags
        end
      end

      def match?(tags)
        return true if self.tags.empty?

        self.tags.each do |tag|
          return true if tags.include?(tag.to_s)
        end

        false
      end
    end

    # @api private
    class HookSet
      def initialize
        @before = []
        @after  = []
        @around = []
      end

      def append(set, hook)
        case set
          when :before then @before << hook
          when :after  then @after << hook
          when :around then @around << hook
          else raise ArgumentError.new "Unknown hook set: #{set}"
        end
      end

      def run(context, world, &block)
        ctx = Context.new context, block
        @before.each {|hook| hook.run world, ctx }
        @around.reduce Context.new(context, block) do |c, e|
          Context.new(context, -> { e.run world, c })
        end.call
      ensure
        @after.each do |hook|
          hook.run world, ctx
        rescue StandardError => e
          warn "Rescued error in after hook: #{e}\n#{e.backtrace.join("\n")}"
        end
      end

      class Context
        extend Forwardable

        def initialize(context, block)
          @context = context
          @block = block
        end

        def tags
          @context.tags.map(&:name)
        end

        def to_proc
          @block
        end

        def call
          @block.call
        end
      end
    end

    # @api private
    class Hook
      attr_reader :opts, :block

      def initialize(opts, &block)
        @opts  = opts
        @block = block
      end

      def match?(context)
        opts.none? {|k, v| context.metadata[k] != v }
      end

      def run(world, *args)
        block = @block
        if world
          world.instance_exec(*args, &block)
        else
          block.call(*args)
        end
      end
    end
  end
end
