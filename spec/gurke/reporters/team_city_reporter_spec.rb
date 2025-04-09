# frozen_string_literal: true

# rubocop:disable Lint/MissingCopEnableDirective

require 'spec_helper'

RSpec.describe Gurke::Reporters::TeamCityReporter do
  subject(:statements) do
    reporter = described_class.new(io: StringIO.new)
    reporter.send(*action)
    reporter.io.string.scan(/##teamcity\[.*\]/)
  end

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

    it 'include a testSuiteStarted command' do
      expect(statements).to eq [
        "##teamcity[testSuiteStarted name='Demo feature']",
      ]
    end
  end

  describe '#before_scenario' do
    let(:action) { [:before_scenario, scenario] }

    before do
      allow(scenario).to receive_messages(name: 'Running the scenario',
        file: File.join(Dir.getwd, 'features', 'file.feature'), line: 5,)
    end

    it do
      expect(statements).to eq [
        "##teamcity[testStarted name='Running the scenario']",
      ]
    end
  end

  describe '#after_scenario' do
    let(:action) { [:after_scenario, scenario] }

    before do
      allow(scenario).to receive_messages(name: 'Running the scenario', passed?: true, failed?: false, pending?: false,
        aborted?: false,)
    end

    it do
      expect(statements).to eq [
        "##teamcity[testFinished name='Running the scenario']",
      ]
    end

    context '<failed>' do
      before do
        error = RuntimeError.new 'An error occurred'
        allow(error).to receive(:backtrace).and_return([
          '/path/to/file.rb:5:in `block (4 levels) in <top (required)>\'',
          '/path/to/file.rb:24:in in `fail_with\'',
        ])

        allow(scenario).to receive_messages(failed?: true, exception: error)
      end

      it do
        # rubocop:disable Layout/LineLength
        expect(statements).to eq [
          "##teamcity[testFailed name='Running the scenario' message='#<RuntimeError: An error occurred>' backtrace='/path/to/file.rb:5:in `block (4 levels) in <top (required)>|$1\\n/path/to/file.rb:24:in in `fail_with|$1']",
          "##teamcity[testFinished name='Running the scenario']",
        ]
        # rubocop:enable Layout/LineLength
      end
    end
  end

  describe '#after_feature' do
    let(:action) { [:after_feature, feature] }

    before do
      allow(feature).to receive(:name).and_return 'Demo feature'
    end

    it do
      expect(statements).to eq [
        "##teamcity[testSuiteFinished name='Demo feature']",
      ]
    end
  end
end
