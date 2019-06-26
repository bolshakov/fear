RSpec.shared_examples Fear::RightBiased::Right do
  describe '#include?' do
    context 'contains value' do
      subject { right.include?('value') }
      it { is_expected.to eq(true) }
    end

    context 'does not contain value' do
      subject { right.include?('another value') }
      it { is_expected.to eq(false) }
    end
  end

  describe '#get_or_else' do
    context 'with block' do
      subject { right.get_or_else { 'default' } }

      it 'returns value' do
        is_expected.to eq('value')
      end
    end

    context 'with nil argument' do
      subject { right.get_or_else { nil } }

      it 'returns value' do
        is_expected.to eq('value')
      end
    end
  end

  describe '#each' do
    subject do
      proc do |block|
        expect(right.each(&block)).to eq(right)
      end
    end

    it 'calls the block with value' do
      is_expected.to yield_with_args('value')
    end
  end

  describe '#or_else' do
    it 'does not call block' do
      expect { |probe| right.or_else(&probe) }.not_to yield_control
    end

    it 'returns the same object' do
      expect(right.or_else { 42 }).to eql(right)
    end
  end

  describe '#map' do
    subject { right.map(&:length) }

    it 'perform transformation' do
      is_expected.to eq(described_class.new(5))
    end
  end

  describe '#flat_map' do
    context 'block returns neither left, nor right' do
      subject { proc { right.flat_map { 42 } } }

      it 'fails with TypeError' do
        is_expected.to raise_error(TypeError)
      end
    end

    context 'block returns RightBiased' do
      subject { right.flat_map { |e| described_class.new("Result: #{e}") } }

      it 'maps to block result' do
        is_expected.to eq(described_class.new('Result: value'))
      end
    end
  end

  describe '#to_option' do
    subject { right.to_option }
    it { is_expected.to eq(Fear::Some.new('value')) }
  end

  describe '#any?' do
    subject { right.any?(&predicate) }

    context 'matches predicate' do
      let(:predicate) { ->(v) { v == 'value' } }
      it { is_expected.to eq(true) }
    end

    context 'does not match predicate' do
      let(:predicate) { ->(v) { v != 'value' } }
      it { is_expected.to eq(false) }
    end
  end

  describe '#===' do
    subject { match === right }

    context 'matches erectly' do
      let(:match) { described_class.new('value') }
      it { is_expected.to eq(true) }
    end

    context 'the same object' do
      let(:match) { right }
      it { is_expected.to eq(true) }
    end

    context 'value does not match' do
      let(:match) { described_class.new('error') }
      it { is_expected.to eq(false) }
    end

    context 'matches by class' do
      let(:match) { described_class.new(String) }
      it { is_expected.to eq(true) }
    end

    context 'does not matches by class' do
      let(:match) { described_class.new(Integer) }
      it { is_expected.to eq(false) }
    end
  end
end
