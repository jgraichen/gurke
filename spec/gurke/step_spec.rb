# frozen_string_literal: true

require 'spec_helper'

describe Gurke::Step do
  let(:step) do
    described_class.new('./fake.feature', 1337, :when, raw)
  end

  let(:reporter) { instance_double Gurke::Reporters::NullReporter }
  let(:runner)   { instance_double Gurke::Runner }
  let(:scenario) { instance_double Gurke::Scenario }
  let(:raw)      { instance_double Gherkin::Formatter::Model::Step }
  let(:world)    { Gurke::World.create }

  before do
    world.class.When 'I run something' do
      true
    end

    allow(raw).to receive(:name).and_return('I run something')
    allow(reporter).to receive(:invoke)
    allow(runner).to receive(:hook) {|_, _, &block| block.call }
    allow(runner).to receive(:with_filtered_backtrace) {|*, &block| block.call }
    allow(scenario).to receive_messages(pending?: false, failed?: false, aborted?: false)
  end

  describe '#run' do
    subject(:result) { step.run(runner, reporter, scenario, world) }

    it 'passes the step' do
      expect(result).to be_passed
    end

    context 'with exception in after step hook' do
      before do
        allow(scenario).to receive(:failed!)

        allow(runner).to receive(:hook) do |_, _, &block|
          block.call
          raise exception
        end
      end

      let(:exception) { RuntimeError.new('faily') }

      it 'fails the step' do
        expect(result).to be_failed
        expect(scenario).to have_received(:failed!)
          .with(exception)
      end
    end

    context 'with exception in before step hook' do
      before do
        allow(scenario).to receive(:failed!)

        allow(runner).to receive(:hook) do
          raise exception
        end
      end

      let(:exception) { RuntimeError.new('faily') }

      it 'fails the step' do
        expect(result).to be_failed
        expect(scenario).to have_received(:failed!)
          .with(exception)
      end
    end
  end
end
