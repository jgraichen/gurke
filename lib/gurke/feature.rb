module Gurke
  class Feature
    #
    # Return path to file containing this feature.
    #
    # @return [String] File path.
    #
    attr_reader :file

    # Return line number where this feature is defined.
    #
    # @return [Fixnum] Line number.
    #
    attr_reader :line

    # List of scenarios this feature specifies.
    #
    # @return [Array<Scenario>] Scenarios.
    #
    attr_reader :scenarios

    # List of backgrounds this feature specifies.
    #
    # @return [Array<Background>] Backgrounds.
    #
    attr_reader :backgrounds

    attr_reader :tags

    # @api private
    attr_reader :raw

    # @api private
    def initialize(file, line, tags, raw)
      @scenarios   = RunList.new
      @backgrounds = RunList.new

      @file = file
      @line = line
      @tags = tags
      @raw  = raw
    end

    def name
      raw.name
    end

    def description
      raw.description
    end

    # Return name of this feature.
    #
    # @return [String] Feature name.
    #
    def name
      raw.name
    end

    def failed?
      scenarios.any?(&:failed?)
    end

    def pending?
      scenarios.any?(&:pending?)
    end

    def self.new(*args)
      if args.size == 1 && (f = args.first).is_a?(self)
        super f.file, f.line, f.tags, f.raw
      else
        super
      end
    end

    # -----------------------------------------------------

    # @api private
    def run(runner, reporter)
      reporter.invoke :before_feature, self

      runner.hook :feature, nil do
        run_feature runner, reporter
      end
    ensure
      reporter.invoke :after_feature, self
    end

    private

    def run_feature(runner, reporter)
      reporter.invoke :start_feature, self

      scenarios.run runner, reporter
    ensure
      reporter.invoke :end_feature, self
    end
  end
end
