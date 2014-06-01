require 'spec_helper'

describe Gurke::RunList do
  let(:reporter) { Gurke::Reporters::NullReporter.new }
  let(:runner)   { double 'runner' }
  let(:object)   { double 'object' }
  let(:list)     { Gurke::RunList.new }

  before do
    list << object
    allow(object).to receive(:run)
  end

  describe '#run' do
    subject { list.run runner, reporter }

    it 'should run all objects' do
      expect(object).to receive(:run).with(runner, reporter)
      subject
    end

    context 'with additional args' do
      subject { list.run runner, reporter, 0, :sym }

      it 'should pass additional args' do
        expect(object).to receive(:run).with(runner, reporter, 0, :sym)
        subject
      end
    end
  end
end
