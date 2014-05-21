require 'gherkin'

module Gurke
  #
  class Builder
    #
    attr_reader :features

    def initialize
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
      @current_feature = Feature.new(@file, raw.line, raw)
      @features << @current_feature
    end

    def background(raw)
      @current_context = Background.new(@file, raw.line, raw)
      @current_feature.backgrounds << @current_context
    end

    def scenario(raw)
      @current_context = Scenario.new(@file, raw.line, raw)
      @current_feature.scenarios << @current_context
    end

    def step(raw)
      @current_context.steps << Step.new(@file, raw.line, raw)
    end

    def eof(*)
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
  end
end
