module Gurke
  #
  class Runner
    attr_reader :builder
    attr_reader :files
    attr_reader :options

    def initialize(files, options = {})
      @options = options
      @files   = files
      @builder = Builder.new options
    end

    def reporter
      @reporter ||= Reporters::DefaultReporter.new
    end

    def run
      files.each{|f| builder.parse(f) }

      reporter.invoke :before, :features, builder.features

      with_hooks(:features, nil, nil) do
        run_features builder.features
      end

      reporter.invoke :finish, :features, builder.features

      !builder.features
        .map(&:scenarios)
        .flatten
        .any?{|s| s.failed? || s.pending? }
    end

    def run_features(features)
      reporter.invoke :start, :features, features

      features.each do |feature|
        run_feature(feature)
      end

      reporter.invoke :end, :features, features
    end

    def run_feature(feature)
      reporter.invoke :before, :feature, feature

      with_hooks(:feature, nil, nil) do
        reporter.invoke :start, :feature, feature

        feature.scenarios.each do |scenario|
          run_scenario(scenario, feature)
        end

        reporter.invoke :end, :feature, feature
      end

      reporter.invoke :finish, :feature, feature
    end

    def run_scenario(scenario, feature)
      reporter.invoke :before, :scenario, scenario, feature

      world = world_for(scenario, feature)

      with_hooks(:scenario, scenario, world) do
        reporter.invoke :start, :scenario, scenario, feature

        feature.backgrounds.each do |background|
          run_background background, scenario, feature, world
        end
        run_steps scenario.steps, scenario, feature, world

        reporter.invoke :end, :scenario, scenario, feature
      end

      reporter.invoke :finish, :scenario, scenario, feature
    end

    def run_background(background, scenario, feature, world)
      reporter.invoke :start, :background, background, scenario, feature

      run_steps background.steps, scenario, feature, world

      reporter.invoke :end, :background, background, scenario, feature
    end

    def run_steps(steps, scenario, feature, world)
      steps.each do |step|
        reporter.invoke :before, :step, step, scenario, feature

        result = with_hooks(:step, nil, world) do
          run_step(step, scenario, feature, world)
        end

        reporter.invoke :finish, :step, result, scenario, feature
      end
    end

    def run_step(step, scenario, feature, world)
      reporter.invoke :start, :step, step, scenario, feature

      result = nil
      with_filtered_backtrace do
        match = Steps.find_step(step, world, step.type)

        if scenario.pending? || scenario.failed?
          result = StepResult.new(step, :skipped)
          return result
        end

        m = world.method(match.method_name)
        world.send match.method_name, *(match.params + [step])[0...m.arity]
      end

      result = StepResult.new(step, :success)
    rescue StepPending => e
      scenario.pending! e
      result = StepResult.new(step, :pending, e)
    rescue => e
      scenario.failed! e
      result = StepResult.new(step, :failed, e)
    ensure
      reporter.invoke :end, :step, result, scenario, feature
    end

    def with_hooks(scope, _context, world, &block)
      Configuration::BEFORE_HOOKS.for(scope).each do |hook|
        hook.run(world)
      end
      rst = Configuration::AROUND_HOOKS.for(scope).reduce(block) do |blk, hook|
        proc { hook.run(world, blk) }
      end.call
      Configuration::AFTER_HOOKS.for(scope).each do |hook|
        hook.run(world)
      end

      rst
    end

    def world_for(scenario, _feature)
      scenario.send(:world)
    end

    def with_filtered_backtrace
      yield
    rescue => e
      unless options[:backtrace]
        base = File.expand_path(Gurke.root.dirname)
        e.backtrace.select!{|l| File.expand_path(l)[0...base.size] == base }
      end
      raise
    end

    #
    class StepResult
      attr_reader :step, :exception, :state

      def initialize(step, state, err = nil)
        @step, @state, @exception = step, state, err
      end

      Gurke::Step.public_instance_methods(false).each do |m|
        define_method(m){|*args| step.send m, *args }
      end

      def failed?
        @state == :failed
      end

      def pending?
        @state == :pending
      end

      def skipped?
        @state == :skipped
      end

      def success?
        @state == :success
      end
    end
  end
end
