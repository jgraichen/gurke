# frozen_string_literal: true

module Gurke::Reporters
  class CompactReporter < NullReporter
    include Colored

    attr_reader :io

    def initialize(io: $stdout, **kwargs)
      @io = io
      super(**kwargs)
    end

    def after_step(result, scenario, *)
      return unless result.state == :failed

      io.print red 'E'
      io.puts

      feature = scenario.feature

      io.print yellow('Feature')
      io.print ': '
      io.print scenario.feature.name
      io.print '   '
      io.print format_location(scenario.feature)
      io.puts

      io.print '  '
      io.print yellow('Scenario')
      io.print ': '
      io.print scenario.name
      io.print '   '
      io.print format_location(scenario)
      io.puts

      background = feature.backgrounds.map(&:steps).flatten

      catch(:break) do
        if background.any?
          io.print '    '
          io.print light_black('Background')
          io.print ':'
          io.puts

          background.each do |step|
            io.print '      '
            io.print yellow(step.keyword)
            io.print ' '
            io.print step.name.gsub(/"(.*?)"/, cyan('\0'))
            io.puts

            throw :break if step == result.step
          end
        end

        scenario.steps.each do |step|
          io.print '    '
          io.print yellow(step.keyword)
          io.print ' '
          io.print step.name.gsub(/"(.*?)"/, cyan('\0'))
          io.puts

          throw :break if step == result.step
        end
      end

      exout = format_exception(result.exception, backtrace: true, indent: 6)
      io.puts red exout
      io.puts ' '
    end

    def after_scenario(scenario)
      if scenario.failed?
        # printed in after_step
      elsif scenario.pending?
        io.print yellow '?'
      elsif scenario.passed?
        io.print green '.'
      elsif scenario.aborted?
        io.puts ' '
      end
    end

    def after_features(features)
      io.puts ' '
      io.puts ' '

      scenarios = features.map(&:scenarios).flatten

      size    = scenarios.size
      passed  = scenarios.count(&:passed?)
      failed  = scenarios.count(&:failed?)
      pending = scenarios.count(&:pending?)
      not_run = size - scenarios.count(&:run?)

      message = "#{scenarios.size} scenarios: "
      message += "#{passed} passed, "
      message += "#{failed} failing, #{pending} pending"
      message += ", #{not_run} not run" if not_run.positive?

      if failed.positive?
        io.puts red message
      elsif pending.positive? || not_run.positive?
        io.puts yellow message
      else
        io.puts green message
      end
    end

    private

    def format_location(obj)
      file = obj.file.to_s
      line = obj.line.to_s
      cwd  = Pathname.new(Dir.getwd)
      path = Pathname.new(file).relative_path_from(cwd).to_s
      path = file if path.length > file.length

      light_black("# #{path}:#{line}")
    end
  end
end
