# frozen_string_literal: true

require 'spec_helper'

describe Gurke::Scenario do
  let(:reporter) { Gurke::Reporters::NullReporter.new }
  let(:runner)   { double 'runner' }
  let(:feature)  { double 'feature' }
  let(:backgrounds) { double('backgrounds') }
  let(:tags) { [] }

  before do
    allow(feature).to receive(:backgrounds).and_return(backgrounds)
    allow(backgrounds).to receive(:run)
    allow(runner).to receive(:hook) {|_, _, &block| block.call }
  end

  let(:scenario) do
    Gurke::Scenario.new(feature, nil, nil, tags, nil)
  end

  describe '#run' do
    subject { scenario.run(runner, reporter) }

    it 'runs all backgrounds' do
      expect(backgrounds).to receive(:run)
        .with(runner, reporter, scenario, scenario.send(:world))

      subject
    end

    it 'runs hook in scenario world' do
      expect(runner).to receive(:hook) do |scope, context, world|
        expect(scope).to eq :scenario
        expect(context).to eq scenario
        expect(world).to eq scenario.send(:world)
      end

      subject
    end

    it 'runs reporter callbacks in correct order' do
      expect(reporter).to receive(:invoke).exactly(4).times do |*args|
        @scopes ||= []
        @scopes << args.first
      end

      subject

      expect(@scopes).to eq %i[before_scenario start_scenario
                               end_scenario after_scenario]
    end

    context 'with retries' do
      let(:step) { double('step') }
      let(:worlds) { Set.new }

      before { scenario.steps << step }

      before do
        allow(runner).to receive(:retries).with(scenario).and_return(1)
      end

      it 'resets the world' do
        expect(step).to receive(:run) do |_, _, scenario, world|
          worlds << world
          scenario.failed!
        end

        expect(step).to receive(:run) do |_, _, scenario, world|
          worlds << world
          scenario.passed!
        end

        subject

        # Expect to have two *different* worlds collected
        expect(worlds.size).to eq 2
      end
    end
  end
end
