module Gurke
  class Hooks
    attr_reader :hooks

    def initialize
      @hooks = {}
    end

    def add(target, &block)
      target.to_s.tap do |target|
        hooks[target] ||= []
        hooks[target] << block
      end
    end

    def invoke(target, *args)
      return unless hooks[target]

      hooks[target].each do |hook|
        hook.call *args
      end
    end

    class << self
      def before; @before ||= new end
      def after; @after ||= new end
    end

    class Formatter < Formatters::Base
      %w(features feature scenario step).each do |name|
        define_method "before_#{name}" do |*args|
          Hooks.before.invoke name, *args
        end
        define_method "after_#{name}" do |*args|
          Hooks.after.invoke name, *args
        end
      end
    end

    ::Gurke::Formatter.use Formatter
  end
end
