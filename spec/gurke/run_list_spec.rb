# frozen_string_literal: true

require 'spec_helper'

describe Gurke::RunList do
  let(:reporter) { instance_double 'Gurke::Reporters::NullReporter' }
  let(:runner)   { instance_double 'Gurke::Runner' }
  let(:object)   { double 'runnable' } # rubocop:disable RSpec/VerifiedDoubles
  let(:list)     { described_class.new }

  before do
    list << object
    allow(object).to receive(:run)
  end

  describe '#run' do
    before { list.run runner, reporter }

    it 'runs all objects' do
      expect(object).to have_received(:run).with(runner, reporter)
    end

    context 'with additional args' do
      before { list.run runner, reporter, 0, :sym }

      it 'passes additional args' do
        expect(object).to have_received(:run).with(runner, reporter, 0, :sym)
      end
    end
  end
end
