# frozen_string_literal: true

require 'stringio'

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

      retry_scenario
    ].freeze

    def initialize(**kwargs); end

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

    # Called when a flaky scenario is retried.
    #
    # @param scenario [Scenario] Current scenario.
    #
    # @api public
    #
    def retry_scenario(_scenario)
      raise NotImplementedError.new \
        "#{self.class.name}#retry_scenario must be implemented in subclass."
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

    def format_exception(err, backtrace: true, indent: 0)
      s = ::StringIO.new
      s << (' ' * indent) << err.class.to_s << ': ' << err.message.strip << "\n"

      if backtrace && err.respond_to?(:backtrace)
        if err.backtrace.nil?
          s << (' ' * indent) << '  <no backtrace available>'
        elsif err.backtrace.empty?
          s << (' ' * indent) << '  <backtrace empty>'
        else
          err.backtrace.each do |bt|
            s << (' ' * indent) << '  ' << bt.strip << "\n"
          end
        end
      end

      if err.respond_to?(:cause) && err.cause.respond_to?(:message)
        s << (' ' * indent) << 'caused by: '
        s << format_exception(
          err.cause, backtrace: backtrace, indent: indent,
        ).strip
      end

      s.string
    end
  end
end
