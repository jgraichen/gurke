# frozen_string_literal: true

# rubocop:disable Lint/MissingCopEnableDirective

require 'spec_helper'

RSpec.describe Gurke::Reporters::DefaultReporter do
  subject(:out) do
    reporter = described_class.new(io: StringIO.new, color: color)
    reporter.send(*action)
    reporter.io.string
  end

  let(:color) { nil }

  let(:feature) { instance_double(Gurke::Feature) }
  let(:scenario) { instance_double(Gurke::Scenario) }
  let(:step) { instance_double(Gurke::Step) }

  describe '#before_feature' do
    let(:action) { [:before_feature, feature] }

    before do
      allow(feature).to receive_messages(name: 'Demo feature', file: File.join(Dir.getwd, 'features', 'file.feature'),
        line: 1, description: <<~DESC.strip,)
          As a developer
          I would like have this spec passed
          In order to work on
        DESC
    end

    it do
      expect(out).to eq unindent <<~TEXT
        Feature: Demo feature   # features/file.feature:1
          As a developer
          I would like have this spec passed
          In order to work on
        .
        .
      TEXT
    end

    context 'with colors' do
      let(:color) { true }

      it 'outputs ASCII color codes' do
        expect(out).to eq unindent <<~TEXT
          \e[0;33;49mFeature\e[0m: Demo feature   \e[0;90;49m# features/file.feature:1\e[0m
          \e[0;90;49m  As a developer
            I would like have this spec passed
            In order to work on\e[0m
          .
          .
        TEXT
      end
    end
  end

  describe '#start_background' do
    let(:action) { [:start_background, feature] }

    it do
      expect(out).to eq unindent <<~TEXT
        .    Background:
        .
      TEXT
    end
  end

  describe '#before_scenario' do
    let(:action) { [:before_scenario, scenario] }

    before do
      allow(scenario).to receive_messages(name: 'Running the scenario',
        file: File.join(Dir.getwd, 'features', 'file.feature'), line: 5,)
    end

    it do
      expect(out).to eq unindent <<~TEXT
        .  Scenario: Running the scenario   # features/file.feature:5
        .
      TEXT
    end
  end

  describe '#before_step' do
    let(:action) { [:before_step, step] }

    before do
      allow(step).to receive_messages(name: 'the scenario is passing', keyword: 'Given')
    end

    it do
      expect(out).to eq unindent <<~TEXT
        .    Given the scenario is passing
      TEXT
    end
  end

  describe '#after_step' do
    let(:action) { [:after_step, result, scenario] }
    let(:result) { instance_double(Gurke::Step::StepResult) }

    before do
      allow(result).to receive(:state).and_return state
    end

    context 'with step passing' do
      let(:state) { :passed }

      it do
        expect(out).to eq unindent <<~TEXT
          . (passed)
          .
        TEXT
      end
    end

    context 'with step pending' do
      let(:state) { :pending }

      it do
        expect(out).to eq unindent <<~TEXT
          . (pending)
          .
        TEXT
      end
    end

    context 'with step nil' do
      let(:state) { nil }

      it do
        expect(out).to eq unindent <<~TEXT
          . (skipped)
          .
        TEXT
      end
    end

    context 'with step failing' do
      let(:state) { :failed }

      before do
        error = instance_double RuntimeError
        cause = instance_double IOError

        allow(error).to receive_messages(class: RuntimeError, message: 'An error occurred', backtrace: [
          '/path/to/file.rb:5:in `block (4 levels) in <top (required)>\'',
          '/path/to/file.rb:24:in in `fail_with\'',
        ], cause: cause,)

        allow(cause).to receive_messages(class: IOError, message: 'Socket closed', backtrace: [
          'script.rb:5:in `a\'',
          'script.rb:10:in `b\'',
        ],)

        allow(result).to receive(:exception).and_return error
      end

      it do
        expect(out).to eq unindent <<~TEXT
          . (failure)
          .        RuntimeError: An error occurred
          .          /path/to/file.rb:5:in `block (4 levels) in <top (required)>'
          .          /path/to/file.rb:24:in in `fail_with'
          .        caused by: IOError: Socket closed
          .          script.rb:5:in `a'
          .          script.rb:10:in `b'
          .
          .
        TEXT
      end
    end
  end

  describe '#retry_scenario' do
    let(:action) { [:retry_scenario, scenario] }

    context 'with normal scenario' do
      before do
        allow(scenario).to receive(:flaky?).and_return(false)
      end

      it do
        expect(out).to eq unindent <<~TEXT
          .
          .  Retry scenario due to previous failure:
          .
          .
        TEXT
      end
    end

    context 'with flaky scenario' do
      before do
        allow(scenario).to receive(:flaky?).and_return(true)
      end

      it do
        expect(out).to eq unindent <<~TEXT
          .
          .  Retry flaky scenario due to previous failure:
          .
          .
        TEXT
      end
    end
  end

  describe '#after_scenario' do
    let(:action) { [:after_scenario, scenario] }

    it do
      expect(out).to eq unindent <<~TEXT
        .
        .
      TEXT
    end
  end

  describe '#after_feature' do
    let(:action) { [:after_feature, feature] }

    it do
      expect(out).to eq unindent <<~TEXT
        .
        .
      TEXT
    end
  end

  describe '#after_features' do
    let(:action) { [:after_features, []] }

    it do
      expect(out).to eq unindent <<~TEXT
        .0 scenarios: 0 failing, 0 pending
        .
        .
      TEXT
    end
  end
end
