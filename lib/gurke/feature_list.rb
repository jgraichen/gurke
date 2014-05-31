module Gurke
  #
  # A {FeatureList} is a list of {Feature} objects.
  #
  class FeatureList < Array
    #
    # Run all features from this list.
    #
    # @return [Boolean] False if any scenario has failed or is pending.
    #
    # @api private
    #
    def run(runner, reporter)
      reporter.invoke :before_features, self

      runner.hook(:features, nil) do
        run_features runner, reporter
      end

      reporter.invoke :after_features, self

      !any?{|s| s.failed? || s.pending? }
    end

    private

    def run_features(runner, reporter)
      reporter.invoke :start_features, self

      each do |feature|
        feature.run runner, reporter
      end
    ensure
      reporter.invoke :end_features, self
    end
  end
end
