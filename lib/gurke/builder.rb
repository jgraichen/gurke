require 'gherkin'

module Gurke
  class Builder
    attr_reader :features, :options

    def initialize(options)
      @options  = options
      @features = FeatureList.new
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
      tags = raw.tags.map{|t| Tag.new @file, t.line, t }

      @feature  = Feature.new(@file, raw.line, tags, raw)
      @scenario = nil
      @type     = nil

      features << @feature
    end

    def background(raw)
      @context = Background.new @file, raw.line, raw
      @type    = nil

      @feature.backgrounds << @context
    end

    def scenario(raw)
      tags  = raw.tags.map{|t| Tag.new @file, t.line, t }
      tags += features.last.tags

      @scenario = Scenario.new @feature, @file, raw.line, tags, raw
      @context  = @scenario
      @type     = nil

      @feature.scenarios << @scenario unless filtered?(@scenario)
    end

    def step(raw)
      @type = lookup_type raw.keyword.strip

      @context.steps << Step.new(@file, raw.line, @type, raw)
    end

    def eof(*)
      @features.reject!{|f| f.scenarios.empty? }
      @feature  = nil
      @scenario = nil
      @context  = nil
      @type     = nil
      @file     = nil
    end

    private

    def lookup_type(keyword)
      case (kw = @keywords.fetch(keyword))
        when :and, :but
          @type
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
