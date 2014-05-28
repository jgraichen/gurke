module Gurke
  #
  module DSL
    def step(regexp, method_name = nil, opts = {}, &block)
      if method_name.is_a?(Hash) && opts.empty?
        method_name, opts = nil, method_name
      end

      if method_name && block_given?
        raise ArgumentError.new <<-EOF.strip
          You can either specify a method name or given a block, not both.
        EOF
      end

      _define_step(regexp, method_name, opts, &block)
    end

    def _define_step(regexp, method_name, opts, &block)
      step = StepDefinition.new(regexp, opts)

      define_method("match: #{step.method_name}") {|name| step.match(name) }

      if block_given?
        define_method("#{step.method_name}", &block)
      elsif method_name
        alias_method "#{step.method_name}", method_name
      end
    end
  end
end
