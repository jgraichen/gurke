require 'fileutils'
require 'headless'

module Gurke
  module Formatters
    class Headless < Base
      attr_reader :tmpdir

      def initialize(*args)
        super

        @tmpdir   = options.delete(:tmpdir) { |el| Dir.mktmpdir }
        @headless = ::Headless.new video: video_options
        @index    = 0
      end

      def video_options
        {
            codec: 'libvpx',
            log_file_path: File.join(tmpdir, 'ffmpeg.log'),
            tmp_file_path: File.join(tmpdir, 'ffmpeg.tmp.webm')
        }
      end

      def dir
        options[:dir] || 'report/recoding'
      end

      def recording?
        !!options[:recording]
      end

      def record_all?
        !!options[:record_all]
      end

      # -- Start / Stop --

      def before_features(features)
        @headless.start
        at_exit { destroy }
      end

      def after_features(features)
        destroy

        # TODO: Dir / Template / Whatever - just test atm
      end

      def before_feature(feature)
        dir = File.join(self.dir.to_s, feature.short_name.to_s)

        FileUtils.rm_rf dir if File.exists? dir
        FileUtils.mkdir_p dir
      end

      # -- Intercept scenarios --

      def before_feature_element(scenario)
        if recording?
          @headless.video.start_capture
        end
      end

      def after_feature_element(scenario)
        if recording?
          if scenario.failed? || record_all?
            # TODO: Dir / Template / Whatever - just test atm

            file = File.join(dir, current.feature.short_name, scenario.name, 'video.webm')
            FileUtils.mkdir_p File.dirname file

            STDERR.puts file

            @headless.video.stop_and_save file
          else
            @headless.video.stop_and_discard
          end
        end

        @index = 0
      end

      # -- Intercept steps --

      def manual_step(step, opts)
        take_sceenshot step
      end

      def after_step(step)
        take_sceenshot step
      end

      private
      def destroy
        @headless.destroy if @headless
      end

      def take_sceenshot(step)
        return if step.background?

        # TODO: Dir / Template / Whatever - just test atm
        file = File.join(dir, current.feature.short_name, current.scenario.name, "#{@index += 1} - #{step.keyword}#{step.name}.png")

        FileUtils.mkdir_p File.dirname file
        @headless.take_screenshot "'#{file.gsub("'", "\\'")}'"
      end
    end
  end
end
