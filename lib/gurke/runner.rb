module Gurke
  #
  class Runner
    attr_reader :builder
    attr_reader :files

    def initialize(files, options = {})
      @options = options
      @files   = files
      @builder = Builder.new
    end

    def reporter
      @reporter ||= Reporter.new
    end

    def run
      files.each{|f| builder.parse(f) }

      with_hooks(:features, nil, nil) do
        run_features builder.features
      end

      !builder.features.map(&:scenarios).flatten.any?{|s| s.failed? || s.pending? }
    end

    def run_features(features)
      reporter.start_features(features)

      features.each do |feature|
        run_feature(feature)
      end

      reporter.finish_features(features)
    end

    def run_feature(feature)
      reporter.start_feature(feature)

      feature.scenarios.each do |scenario|
        run_scenario(scenario, feature)
      end

      reporter.finish_feature(feature)
    end

    def run_scenario(scenario, feature)
      reporter.start_scenario(scenario, feature)

      world = world_for(scenario, feature)

      with_hooks(:scenario, scenario, world) do
        feature.backgrounds.each{|b| run_background(b, scenario, feature, world) }
        scenario.steps.each{|s| run_step(s, scenario, feature, world) }
      end

      reporter.finish_scenario(scenario, feature)
    end

    def run_background(background, scenario, feature, world)
      reporter.start_background(background)

      background.steps.each{|s| run_step(s, scenario, feature, world) }

      reporter.finish_background(background)
    end

    def run_step(step, scenario, feature, world)
      reporter.start_step(step, scenario, feature)

      result = nil
      with_filtered_backtrace do
        match = Steps.find_step(step, world)

        if scenario.pending? || scenario.failed?
          result = StepResult.new(step, :skipped)
          return
        end

        m = world.method(match.method_name)
        world.send match.method_name, *(match.params + [step])[0...m.arity]
      end

      result = StepResult.new(step, :success)
    rescue StepPending => e
      scenario.pending! e
      result = StepResult.new(step, :pending, e)
    rescue Exception => e
      scenario.failed! e
      result = StepResult.new(step, :failed, e)
    ensure
      reporter.finish_step(result, scenario, feature)
    end

    def with_hooks(scope, context, world, &block)
      Gurke::Configuration::BEFORE_HOOKS.for(scope).each do |hook|
        hook.run(world)
      end
      Gurke::Configuration::AROUND_HOOKS.for(scope).inject(block) do |block, hook|
        proc { hook.run(world, block) }
      end.call
      Gurke::Configuration::AFTER_HOOKS.for(scope).each do |hook|
        hook.run(world)
      end
    end

    def world_for(scenario, feature)
      scenario.send(:world)
    end

    def with_filtered_backtrace
      yield
    rescue Exception => e
      base = File.expand_path(Gurke.root.dirname)
      e.backtrace.select!{|line| File.expand_path(line)[0...base.size] == base }
      raise
    end

    class StepResult
      attr_reader :step, :exception, :state

      def initialize(step, state, err = nil)
        @step, @state, @exception = step, state, err
      end

      Gurke::Step.public_instance_methods(false).each do |m|
        define_method(m) {|*args| step.send m, *args }
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
