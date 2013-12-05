require 'active_support/core_ext/string/inflections'
require 'gurke/formatters/base'

module Gurke
  class Formatter
    attr_reader :runtime, :options
    attr_reader :current_feature, :current_step

    def initialize(runtime, path_or_io, options)
      @runtime, @path_or_io, @options = runtime, path_or_io, options

      self.class.formatters.each do |klass, opts|
        if klass.respond_to?(:gurkig?) && klass.gurkig?
          formatters << klass.new(self, opts)
        else
          legacy << klass.new(runtime, path_or_io, options)
        end
      end

      self.class.instance = self
    end

    def formatters
      @formatters ||= []
    end

    def legacy
      @legacy ||= []
    end

    ## -- Before callbacks --

    def before_features(features)
      invoke :before, :features, [features]
    end

    def before_feature(feature)
      invoke :before, :feature, [feature]
    end

    def before_tags(tags)
      invoke :before, :tags, [tags]
    end

    def before_background(background)
      invoke :before, :background, [background]
    end

    def before_steps(steps)
      invoke :before, :steps, [steps]
    end

    def before_step(step)
      invoke :before, :step, [step]
    end

    def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line)
      invoke :before, :step_result, [keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line]
    end

    def before_feature_element(element)
      invoke :before, :feature_element, [element]
      invoke :before, :scenario, args: [element]
    end

    ## -- Element callbacks --

    def manual_step(step, opts)
      invoke nil, :manual_step, args: [step, opts]
    end

    def feature_name(name, description)
      invoke nil, :feature_name, [name, description]
    end

    def tag_name(name)
      invoke nil, :tag_name, [name]
    end

    def background_name(keyword, name, file_colon_line, source_indent)
      invoke nil, :background_name, [keyword, name, file_colon_line, source_indent]
    end

    def scenario_name(keyword, name, file_colon_line, source_indent)
      invoke nil, :scenario_name, [keyword, name, file_colon_line, source_indent]
    end

    def step_name(keyword, step_match, status, source_indent, background, file_colon_line)
      invoke nil, :step_name, [keyword, step_match, status, source_indent, background, file_colon_line]
    end

    def exception(exception, status)
      invoke nil, :exception, [exception, status]
    end

    ## -- After callbacks --

    def after_feature_element(element)
      invoke :after, :feature_element, [element]
      invoke :after, :scenario, args: [element]
    end

    def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line)
      invoke :after, :step_result, [keyword, step_match, multiline_arg, status, exception, source_indent, background, file_colon_line]
    end

    def after_step(step)
      invoke :after, :step, [step]
    end

    def after_steps(steps)
      invoke :after, :steps, [steps]
    end

    def after_background(background)
      invoke :after, :background, [background]
    end

    def after_tags(tags)
      invoke :after, :tags, [tags]
    end

    def after_feature(feature)
      invoke :after, :feature, [feature]
    end

    def after_features(features)
      invoke :after, :features, [features]
    end

    private
    def invoke(type, name, args = {})
      args = { args: args, legacy: args } if Array === args

      if args[:args]
        (type == :after ? formatters.reverse : formatters).each do |fmt|
          mth = type.nil? ? name : "#{type}_#{name}"
          fmt.send mth, *args[:args] if fmt.respond_to? mth
        end
      end

      if args[:legacy]
        legacy.each do |fmt|
          mth = type.nil? ? name : "#{type}_#{name}"
          fmt.send mth, *args[:legacy] if fmt.respond_to? mth
        end
      end
    end

    class << self
      attr_reader :legacy_formatter
      attr_accessor :instance

      def formatters
        @formatters ||= {}
      end

      def config(&block)
        instance_eval &block
      end

      def use(formatter, options = {})
        klass = lookup_formatter(formatter)
        raise InvalidArgument.new 'Cannot find formatters `#{formatters}\'.' unless klass

        formatters[klass] = options
      end

      private
      def lookup_formatter(formatter)
        return formatter if formatter.is_a? Class
        formatter.camelize.safe_constantize
      end
    end
  end
end

