RSpec.describe Functional::Success do
  let(:success) { described_class.new('value') }

  it_behaves_like Functional::RightBiased::Right do
    let(:right) { success }

    describe '#map', 'block fails' do
      subject(:map) { right.map { fail 'unexpected error' } }

      it { is_expected.to be_kind_of(Functional::Failure) }
      it { expect { map.get }.to raise_error(RuntimeError, 'unexpected error') }
    end

    describe '#flat_map', 'block fails' do
      subject(:flat_map) { right.flat_map { fail 'unexpected error' } }

      it { is_expected.to be_kind_of(Functional::Failure) }
      it { expect { flat_map.get }.to raise_error(RuntimeError, 'unexpected error') }
    end
  end

  describe '#get' do
    subject { success.get }
    it { is_expected.to eq('value') }
  end

  describe '#success?' do
    subject { success }
    it { is_expected.to be_success }
  end

  describe '#or_else' do
    subject { success.or_else { described_class.new('another value') } }
    it { is_expected.to eq(success) }
  end

  describe '#flatten' do
    subject { described_class.new(value).flatten }

    context 'value is a Success' do
      let(:value) { described_class.new(42) }
      it { is_expected.to eq(described_class.new(42)) }
    end

    context 'value is a Success of Success' do
      let(:value) { described_class.new(described_class.new(42)) }
      it { is_expected.to eq(described_class.new(42)) }
    end

    context 'value is a Success of Failure' do
      let(:failure) { Functional::Failure.new(RuntimeError.new) }
      let(:value) { described_class.new(failure) }
      it { is_expected.to eq(failure) }
    end
  end

  describe '#detect' do
    context 'predicate holds for value' do
      subject { success.detect { |v| v == 'value' } }
      it { is_expected.to eq(success) }
    end

    context 'predicate does not hold for value' do
      subject { proc { success.detect { |v| v != 'value' }.get } }
      it { is_expected.to raise_error(Functional::NoSuchElementError, 'Predicate does not hold for `value`') }
    end

    context 'predicate fails with error' do
      subject { proc { success.detect { fail 'foo' }.get } }
      it { is_expected.to raise_error(RuntimeError, 'foo') }
    end
  end

  describe '#recover_with' do
    subject { success.recover_with { |v| Success(v * 2) } }
    it { is_expected.to eq(success) }
  end

  describe '#recover' do
    subject { success.recover { |v| v * 2 } }
    it { is_expected.to eq(success) }
  end
end
