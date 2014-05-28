require 'gherkin'

module Gurke
  #
  class Builder
    #
    attr_reader :features, :options

    def initialize(options)
      @options  = options
      @features = []
      @language = 'en'
      @parser   = Gherkin::Parser::Parser.new(
        self, true, 'root', false, @language)

      @keywords = {}
      Gherkin::I18n::LANGUAGES[@language].each do |k, v|
        v.split('|').map(&:strip).each do |str|
          @keywords[str] = k.to_sym if str != '*'
        end
      end
    end

    def parse(feature_file)
      @parser.parse(File.read(feature_file), feature_file, 0)
    end

    def uri(raw)
      @file = raw.to_s
    end

    def feature(raw)
      tags = raw.tags.map{|t| Tag.new(@file, t.line, t) }

      @current_feature = Feature.new(@file, raw.line, tags, raw)
      @features << @current_feature
    end

    def background(raw)
      @current_context = Background.new(@file, raw.line, raw)
      @current_feature.backgrounds << @current_context
    end

    def scenario(raw)
      tags = raw.tags.map{|t| Tag.new(@file, t.line, t) }
      tags += @current_feature.tags

      @current_context = Scenario.new(@file, raw.line, tags, raw)

      unless filtered?(@current_context)
        @current_feature.scenarios << @current_context
      end
    end

    def step(raw)
      @current_context.steps << Step.new(@file, raw.line, raw)
    end

    def eof(*)
      @features.reject!{|f| f.scenarios.empty? }
      @current_context = nil
      @current_feature = nil
      @file            = nil
    end

    def get_type(keyword)
      case (kw = @keywords.fetch(keyword))
        when :and, :but
          if (step = @current_context.steps.last)
            step.type
          else
            nil
          end
        else
          kw
      end
    end

    def filter_sets
      @filter_sets ||= options[:tags].map do |list|
        list.strip.split(/[,+\s]\s*/).map{|t| Filter.new(t) }
      end
    end

    def filtered?(scenario)
      !filter_sets.reduce(false) do |memo, set|
        memo || set.all?{|rule| rule.match? scenario }
      end
    end

    Filter = Struct.new(:tag) do
      def name
        @name ||= negated? ? tag[1..-1] : tag
      end

      def negated?
        tag[0] == '~'
      end

      def match?(taggable)
        negated? != taggable.tags.any?{|t| t.name == name }
      end
    end
  end
end
