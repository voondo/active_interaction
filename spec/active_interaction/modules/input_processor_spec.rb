# coding: utf-8

require 'spec_helper'

describe ActiveInteraction::InputProcessor do
  describe '.reserved?(name)' do
    it 'returns true for anything starting with "_interaction_"' do
      expect(described_class.reserved?('_interaction_')).to be_truthy
    end

    it 'returns false for anything else' do
      expect(described_class.reserved?(SecureRandom.hex)).to be_falsey
    end
  end

  describe '.process(inputs)' do
    let(:inputs) { {} }
    let(:result) { described_class.process(inputs) }

    context 'with simple inputs' do
      before { inputs[:key] = :value }

      it 'sends them straight through' do
        expect(result).to eql inputs
      end
    end

    context 'with groupable inputs' do
      context 'without a matching simple input' do
        before do
          inputs.merge!(
            'key(1i)' => :value1,
            'key(2i)' => :value2
          )
        end

        it 'groups the inputs into a GroupedInput' do
          expect(result).to eq(
            key: ActiveInteraction::GroupedInput.new(
              '1' => :value1,
              '2' => :value2
            )
          )
        end
      end

      context 'with a matching simple input' do
        before do
          inputs.merge!(
            'key(1i)' => :value1,
            key: :value2
          )
        end

        it 'groups the inputs into a GroupedInput' do
          expect(result).to eq(
            key: ActiveInteraction::GroupedInput.new(
              '1' => :value1
            )
          )
        end
      end
    end

    context 'with a reserved name' do
      before { inputs[:_interaction_key] = :value }

      it 'raises an error' do
        expect do
          result
        end.to raise_error ActiveInteraction::ReservedNameError
      end
    end
  end
end
