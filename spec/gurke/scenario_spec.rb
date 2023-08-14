# frozen_string_literal: true

require 'spec_helper'

describe Gurke::Scenario do
  let(:scenario) do
    described_class.new(feature, nil, nil, tags, nil)
  end

  let(:reporter) { instance_double Gurke::Reporters::NullReporter }
  let(:runner)   { instance_double Gurke::Runner }
  let(:feature)  { instance_double Gurke::Feature }
  let(:backgrounds) { instance_double Gurke::RunList }
  let(:tags) { [] }

  before do
    allow(reporter).to receive(:invoke)
    allow(backgrounds).to receive(:run)
    allow(feature).to receive(:backgrounds).and_return(backgrounds)
    allow(runner).to receive(:hook) {|_, _, &block| block.call }
  end

  describe '#run' do
    subject(:run) { scenario.run(runner, reporter) }

    context 'when running' do
      before { run }

      it 'has run all backgrounds' do
        expect(backgrounds).to have_received(:run)
          .with(runner, reporter, scenario, scenario.send(:world))
      end

      it 'has hooked in the scenario world' do
        expect(runner).to have_received(:hook) do |scope, context, world|
          expect(scope).to eq :scenario
          expect(context).to eq scenario
          expect(world).to eq scenario.send(:world)
        end
      end

      it 'has invoked reporter callbacks in correct order' do
        scopes = []
        expect(reporter).to have_received(:invoke).exactly(4).times do |*args|
          scopes << args.first
        end

        expect(scopes).to eq %i[
          before_scenario
          start_scenario
          end_scenario
          after_scenario
        ]
      end
    end

    context 'with retries' do
      let(:step) { instance_double(Gurke::Step) }
      let(:worlds) { Set.new }

      before do
        scenario.steps << step
        allow(runner).to receive(:retries).with(scenario).and_return(1)
      end

      it 'resets the world' do
        # rubocop:disable RSpec/MessageSpies
        expect(step).to receive(:run) do |_, _, scenario, world|
          worlds << world
          scenario.failed!
        end

        expect(step).to receive(:run) do |_, _, scenario, world|
          worlds << world
          scenario.passed!
        end

        run

        # Expect to have two *different* worlds collected
        expect(worlds.size).to eq 2

        # rubocop:enable RSpec/MessageSpies
      end
    end
  end
end
