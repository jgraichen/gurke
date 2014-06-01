module Gurke
  class Configuration
    #
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
          step: HookSet.new
        }

        hooks.merge each: hooks[:scenario]
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

      def run(world, &block)
        @before.each{|hook| hook.run world }
        @around.reduce(block){|a, e| proc{ e.run world, a }}.call
      ensure
        @after.each do |hook|
          begin
            hook.run world
          rescue => e
            warn "Rescued error in after hook: #{e}\n#{e.backtrace.join("\n")}"
          end
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
        !opts.any?{|k, v| context.metadata[k] != v }
      end

      def run(context, *args)
        block = @block
        if context
          context.instance_exec(*args, &block)
        else
          block.call(*args)
        end
      end
    end
  end
end
