RSpec.shared_examples Fear::RightBiased::Left do
  describe '#include?' do
    subject { left }
    it { is_expected.not_to include('value') }
  end

  describe '#get_or_else' do
    context 'with block' do
      subject { left.get_or_else { 'default' } }

      it 'returns default value' do
        is_expected.to eq('default')
      end
    end

    context 'with default argument' do
      subject { left.get_or_else('default') }

      it 'returns default value' do
        is_expected.to eq('default')
      end
    end

    context 'with false argument' do
      subject { left.get_or_else(false) }

      it 'returns default value' do
        is_expected.to eq(false)
      end
    end

    context 'with nil argument' do
      subject { left.get_or_else(nil) }

      it 'returns default value' do
        is_expected.to eq(nil)
      end
    end
  end

  describe '#each' do
    subject do
      proc do |block|
        expect(left.each(&block)).to eq(left)
      end
    end

    it 'does not call the block' do
      is_expected.not_to yield_control
    end
  end

  describe '#map' do
    subject { left.map(&:length) }

    it 'returns self' do
      is_expected.to eq(left)
    end
  end

  describe '#flat_map' do
    subject { left.flat_map(&:length) }

    it 'returns self' do
      is_expected.to eq(left)
    end
  end

  describe '#to_a' do
    subject { left.to_a }
    it { is_expected.to eq([]) }
  end

  describe '#to_option' do
    subject { left.to_option }
    it { is_expected.to eq(Fear::None) }
  end

  describe '#any?' do
    subject { left.any? { |v| v == 'value' } }
    it { is_expected.to eq(false) }
  end

  describe '#===' do
    subject { match === left }

    context 'the same object' do
      let(:match) { left }
      it { is_expected.to eq(true) }
    end
  end
end
