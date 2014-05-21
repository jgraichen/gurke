module Gurke
  #
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
      BEFORE_HOOKS.append action, Hook.new(opts, &block)
    end

    def around(action = :scenario, opts = nil, &block)
      AROUND_HOOKS.append action, Hook.new(opts, &block)
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
      AFTER_HOOKS.append action, Hook.new(opts, &block)
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
      @hooks ||= Hooks.new
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
      attr_reader :hooks

      def initialize
        @hooks = {}
      end

      def for(action)
        hooks[action] ||= []
      end

      def append(action, hook)
        self.for(action) << hook
      end
    end

    BEFORE_HOOKS = HookSet.new
    AROUND_HOOKS = HookSet.new
    AFTER_HOOKS  = HookSet.new

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
        context.instance_exec(*args, &block)
      end
    end
  end
end
