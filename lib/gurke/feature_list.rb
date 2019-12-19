# frozen_string_literal: true

module Gurke
  #
  # A {FeatureList} is a list of {Feature} objects.
  #
  class FeatureList < Array
    #
    # Run all features from this list.
    #
    # @return [Boolean] False if any scenario has failed.
    #
    # @api private
    #
    def run(runner, reporter)
      reporter.invoke :before_features, self

      runner.hook(:features, nil, nil) do
        run_features runner, reporter
      end

      reporter.invoke :after_features, self

      !any?(&:failed?)
    end

    # @api private
    def filter(options, files)
      list   = FeatureList.new
      filter = Filter.new options, files

      each do |feature|
        file, _lines = files.select {|f, _| f == feature.file }.first
        next unless file

        f = Feature.new(feature)

        feature.scenarios.each do |scenario|
          f.scenarios << scenario unless filter.filtered?(scenario)
        end

        list << f if f.scenarios.any?
      end

      list
    end

    private

    def run_features(runner, reporter)
      reporter.invoke :start_features, self

      each do |feature|
        feature.run runner, reporter
      end
    rescue Interrupt # rubocop:disable Lint/SuppressedException
      # nothing
    ensure
      reporter.invoke :end_features, self
    end

    class Filter
      attr_reader :options, :files

      def initialize(options, files)
        @options = options
        @files   = files
      end

      def tag_filters
        @tag_filters ||= options[:tags].map do |list|
          list.strip.split(/[,+\s]\s*/).map {|t| TagFilter.new(t) }
        end
      end

      def filtered?(scenario)
        filtered_by_tags?(scenario) || filtered_by_line?(scenario)
      end

      def filtered_by_tags?(scenario)
        !tag_filters.reduce(false) do |memo, set|
          memo || set.all? {|rule| rule.match? scenario }
        end
      end

      def filtered_by_line?(scenario)
        _, lines = files.select {|f, _| f == scenario.file }.first

        return false if lines.empty?

        lines.none? {|l| scenario.line <= l && scenario.steps.last.line >= l }
      end

      TagFilter = Struct.new(:tag) do
        def name
          @name ||= negated? ? tag[1..-1] : tag
        end

        def negated?
          tag[0] == '~'
        end

        def match?(taggable)
          negated? != taggable.tags.any? {|t| t.name == name }
        end
      end
    end
  end
end
