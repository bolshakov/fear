RSpec.describe Fear::Failure do
  let(:failure) { described_class.new(RuntimeError.new('error')) }

  it_behaves_like Fear::RightBiased::Left do
    let(:left) { failure }
  end

  describe '#success?' do
    subject { failure }
    it { is_expected.not_to be_success }
  end

  describe '#get' do
    subject { proc { failure.get } }
    it { is_expected.to raise_error(RuntimeError, 'error') }
  end

  describe '#or_else' do
    context 'default does not fail' do
      subject { failure.or_else { 'value' } }
      it { is_expected.to eq(Fear::Success.new('value')) }
    end

    context 'default fails with error' do
      subject(:or_else) { failure.or_else { fail 'unexpected error' } }
      it { is_expected.to be_kind_of(described_class) }
      it { expect { or_else.get }.to raise_error(RuntimeError, 'unexpected error') }
    end
  end

  describe '#flatten' do
    subject { failure.flatten }
    it { is_expected.to eq(failure) }
  end

  describe '#detect' do
    subject { failure.detect { |v| v == 'value' } }
    it { is_expected.to eq(failure) }
  end

  context '#recover_with' do
    context 'block does not fail' do
      subject do
        failure.recover_with do |error|
          Fear::Success.new(error.message)
        end
      end

      it 'returns result of evaluation of the block against the error' do
        is_expected.to eq(Fear::Success.new('error'))
      end
    end

    context 'block fails' do
      subject(:recover_with) { failure.recover_with { fail 'unexpected error' } }

      it { is_expected.to be_kind_of(described_class) }
      it { expect { recover_with.get }.to raise_error(RuntimeError, 'unexpected error') }
    end
  end

  context '#recover' do
    context 'block does not fail' do
      subject { failure.recover(&:message) }

      it 'returns Success of evaluation of the block against the error' do
        is_expected.to eq(Fear::Success.new('error'))
      end
    end

    context 'block fails' do
      subject(:recover) { failure.recover { fail 'unexpected error' } }

      it { is_expected.to be_kind_of(described_class) }
      it { expect { recover.get }.to raise_error(RuntimeError, 'unexpected error') }
    end
  end
end
