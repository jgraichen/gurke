module Gurke
  #
  module DSL
    def step(pattern, method_name = nil, opts = {}, &block)
      if method_name.is_a?(Hash) && opts.empty?
        method_name, opts = nil, method_name
      end

      if method_name && block_given?
        raise ArgumentError.new <<-EOF.strip
          You can either specify a method name or given a block, not both.
        EOF
      end

      _define_step(pattern, method_name, opts, &block)
    end

    def _define_step(pattern, method_name, opts, &block)
      step = StepDefinition.new(pattern, opts)

      define_method("match: #{step.method_name}") do |name, s = nil|
        step.match(name, s)
      end

      if block_given?
        define_method("#{step.method_name}", &block)
      elsif method_name
        alias_method "#{step.method_name}", method_name
      end
    end

    def Given(pattern, method_name = nil, opts = {}, &block)
      step pattern, method_name, opts.merge(type: :given), &block
    end

    def When(pattern, method_name = nil, opts = {}, &block)
      step pattern, method_name, opts.merge(type: :when), &block
    end

    def Then(pattern, method_name = nil, opts = {}, &block)
      step pattern, method_name, opts.merge(type: :then), &block
    end
  end
end
