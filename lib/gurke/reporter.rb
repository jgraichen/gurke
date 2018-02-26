# frozen_string_literal: true

module Gurke
  #
  # A {Reporter} provides callbacks that will be executed whenever
  # a specific execution step starts or ends.
  #
  # @api public
  #
  #
  class Reporter
    # List of all callback methods as symbols.
    #
    CALLBACKS = %i[
      before_features
      before_feature
      before_scenario
      before_step
      start_features
      start_feature
      start_scenario
      start_background
      start_step
      end_features
      end_feature
      end_scenario
      end_background
      end_step
      after_features
      after_feature
      after_scenario
      after_step
    ].freeze

    # Called before the execution of any feature and before any
    # before-features hook is invoked.
    #
    # @param features [Array<Feature>] List of all features that
    #   are going to be executed.
    #
    # @api public
    #
    def before_features(_features)
      raise NotImplementedError.new \
        "#{self.class.name}#before_features must be implemented in subclass."
    end

    # Called before the execute of any feature, but after all
    # before-features hooks.
    #
    # @param features [Array<Feature>] List of all features that
    #   are going to be executed.
    #
    # @api public
    #
    def start_features(_features)
      raise NotImplementedError.new \
        "#{self.class.name}#before_features must be implemented in subclass."
    end

    # Called for each feature before it starts, but before any
    # before-feature hook is run.
    #
    # @param feature [Feature] The feature that is going to
    #   be executed now.
    #
    # @api public
    #
    def before_feature(_feature)
      raise NotImplementedError.new \
        "#{self.class.name}#start_feature must be implemented in subclass."
    end

    # Called for each feature before it starts, but after
    # all before-feature hooks.
    #
    # @param feature [Feature] The feature that is going to
    #   be executed now.
    #
    # @api public
    #
    def start_feature(_feature)
      raise NotImplementedError.new \
        "#{self.class.name}#start_feature must be implemented in subclass."
    end

    # Called for each each scenario before it starts. Will be
    # called before any hooks for the given scenario is executed.
    #
    # @param scenario [Scenario] Current scenario.
    #
    # @api public
    #
    def before_scenario(_scenario)
      raise NotImplementedError.new \
        "#{self.class.name}#before_scenario must be implemented in subclass."
    end

    # Called for each each scenario before it starts, but after
    # all before hooks for given scenario.
    #
    # @param scenario [Scenario] Current scenario.
    #
    # @api public
    #
    def start_scenario(_scenario)
      raise NotImplementedError.new \
        "#{self.class.name}#start_scenario must be implemented in subclass."
    end

    # Called before each background.
    #
    # @param background [Background] Current background.
    # @param scenario [Scenario] Current scenario.
    #
    # @api public
    #
    def start_background(_background, _scenario)
      raise NotImplementedError.new \
        "#{self.class.name}#start_background must be implemented in subclass."
    end

    # Called after each background.
    #
    # @param background [Background] Current background.
    # @param scenario [Scenario] Current scenario.
    #
    # @api public
    #
    def end_background(_background, _scenario)
      raise NotImplementedError.new \
        "#{self.class.name}#end_background must be implemented in subclass."
    end

    # Called before each step and before any before-step hook.
    #
    # @param step [Step] Current Step.
    # @param scenario [Scenario] Current scenario.
    #
    # @api public
    #
    def before_step(_step, _scenario)
      raise NotImplementedError.new \
        "#{self.class.name}#before_step must be implemented in subclass."
    end

    # Called before each step and after all before-step hooks.
    #
    # @param step [Step] Current Step.
    # @param scenario [Scenario] Current scenario.
    #
    # @api public
    #
    def start_step(_step, _scenario)
      raise NotImplementedError.new \
        "#{self.class.name}#start_step must be implemented in subclass."
    end

    # Called after each step but before any after-step hook.
    #
    # @param step_result [StepResult] Result of current Step.
    # @param scenario [Scenario] Current scenario.
    # @param feature [Feature] Current feature.
    #
    # @api public
    #
    def end_step(_step_result, _scenario)
      raise NotImplementedError.new \
        "#{self.class.name}#end_step must be implemented in subclass."
    end

    # Called after each step, after all step hook.
    #
    # @param step_result [StepResult] Result of current Step.
    # @param scenario [Scenario] Current scenario.
    # @param feature [Feature] Current feature.
    #
    # @api public
    #
    def after_step(_step_result, _scenario)
      raise NotImplementedError.new \
        "#{self.class.name}#after_step must be implemented in subclass."
    end

    # Called after each scenario but before any after hook.
    #
    # @param scenario [Scenario] Current scenario.
    # @param feature [Feature] Current feature.
    #
    # @api public
    #
    def end_scenario(_scenario)
      raise NotImplementedError.new \
        "#{self.class.name}#end_scenario must be implemented in subclass."
    end

    # Called after each scenario and after all hooks.
    #
    # @param scenario [Scenario] Current scenario.
    # @param feature [Feature] Current feature.
    #
    # @api public
    #
    def after_scenario(_scenario)
      raise NotImplementedError.new \
        "#{self.class.name}#after_scenario must be implemented in subclass."
    end

    # Called after each feature but before any after hook.
    #
    # @param feature [Feature] Current feature.
    #
    # @api public
    #
    def end_feature(_feature)
      raise NotImplementedError.new \
        "#{self.class.name}#end_feature must be implemented in subclass."
    end

    # Called after each feature and after all hooks.
    #
    # @param feature [Feature] Current feature.
    #
    # @api public
    #
    def after_feature(_feature)
      raise NotImplementedError.new \
        "#{self.class.name}#after_feature must be implemented in subclass."
    end

    # Called after all features but before any after-features hook.
    #
    # @param features [Array<Feature>] List of all features.
    #
    # @api public
    #
    def end_features(_features)
      raise NotImplementedError.new \
        "#{self.class.name}#end_features must be implemented in subclass."
    end

    # Called after all features and after all hooks.
    #
    # @param features [Array<Feature>] List of all features.
    #
    # @api public
    #
    def after_features(_features)
      raise NotImplementedError.new \
        "#{self.class.name}#after_features must be implemented in subclass."
    end

    # @visibility private
    def invoke(mth, *args)
      send mth, *args
    rescue StandardError => e
      warn "Rescued in reporter: #{e}\n" + e.backtrace.join("\n")
    end

    # @api private
    #

    protected

    def format_exception(ex, backtrace: true)
      s = ex.class.to_s << ': ' << ex.message.strip << "\n"

      if backtrace
        if ex.backtrace.nil?
          s << '  <no backtrace available>'
        elsif ex.backtrace.empty?
          s << '  <backtrace empty>'
        else
          ex.backtrace.each do |bt|
            s << '  ' << bt.strip << "\n"
          end
        end
      end

      if ex.respond_to?(:cause) && ex.cause &&
         ex.cause.respond_to?(:message) && ex.cause.respond_to?(:backtrace)

        s << 'caused by: ' << format_exception(ex.cause, backtrace: backtrace)
      end

      s
    end
  end
end
