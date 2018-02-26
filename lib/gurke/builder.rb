# frozen_string_literal: true

require 'gherkin'

module Gurke
  class Builder
    attr_reader :features
    attr_writer :keywords

    def initialize
      @language = 'en'
      @parser   = Gherkin::Parser::Parser.new(
        self, true, 'root', false, @language
      )
    end

    def keywords
      @keywords ||= begin
        keywords = {}
        Gherkin::I18n::LANGUAGES[@language].each do |k, v|
          v.split('|').map(&:strip).each do |str|
            keywords[str] = k.to_sym if str != '*'
          end
        end

        keywords
      end
    end

    def load(files)
      FeatureList.new.tap do |fl|
        @features = fl

        files.each do |file|
          @parser.parse File.read(file), file, 0
        end

        @features = nil
      end
    end

    def uri(raw)
      @file = raw.to_s
    end

    def feature(raw)
      tags = raw.tags.map {|t| Tag.new @file, t.line, t }

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
      tags  = raw.tags.map {|t| Tag.new @file, t.line, t }
      tags += features.last.tags

      @scenario = Scenario.new @feature, @file, raw.line, tags, raw
      @context  = @scenario
      @type     = nil

      @feature.scenarios << @scenario
    end

    def step(raw)
      @type = lookup_type raw.keyword.strip

      @context.steps << Step.new(@file, raw.line, @type, raw)
    end

    def eof(*)
      @features.reject! {|f| f.scenarios.empty? }
      @feature  = nil
      @scenario = nil
      @context  = nil
      @type     = nil
      @file     = nil
    end

    private

    def lookup_type(keyword)
      case (kw = keywords.fetch(keyword))
        when :and, :but
          @type
        else
          kw
      end
    end
  end
end
