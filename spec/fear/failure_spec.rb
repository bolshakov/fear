RSpec.describe Fear::Failure do
  let(:exception) { RuntimeError.new('error') }
  let(:failure) { Fear.failure(exception) }

  it_behaves_like Fear::RightBiased::Left do
    let(:left) { failure }
  end

  describe '#exception' do
    subject { failure.exception }
    it { is_expected.to eq(exception) }
  end

  describe '#success?' do
    subject { failure }
    it { is_expected.not_to be_success }
  end

  describe '#failure?' do
    subject { failure }
    it { is_expected.to be_failure }
  end

  describe '#get' do
    subject { proc { failure.get } }
    it { is_expected.to raise_error(RuntimeError, 'error') }
  end

  describe '#or_else' do
    context 'default does not fail' do
      subject { failure.or_else { Fear::Success.new('value') } }
      it { is_expected.to eq(Fear::Success.new('value')) }
    end

    context 'default fails with error' do
      subject(:or_else) { failure.or_else { raise 'unexpected error' } }
      it { is_expected.to be_kind_of(described_class) }
      it { expect { or_else.get }.to raise_error(RuntimeError, 'unexpected error') }
    end
  end

  describe '#flatten' do
    subject { failure.flatten }
    it { is_expected.to eq(failure) }
  end

  describe '#select' do
    subject { failure.select { |v| v == 'value' } }
    it { is_expected.to eq(failure) }
  end

  context '#recover_with' do
    context 'block does not fail' do
      subject do
        failure.recover_with do |error|
          Fear.success(error.message)
        end
      end

      it 'returns result of evaluation of the block against the error' do
        is_expected.to eq(Fear::Success.new('error'))
      end
    end

    context 'block fails' do
      subject(:recover_with) { failure.recover_with { raise 'unexpected error' } }

      it { is_expected.to be_kind_of(described_class) }
      it { expect { recover_with.get }.to raise_error(RuntimeError, 'unexpected error') }
    end
  end

  context '#recover' do
    context 'block does not fail' do
      subject { failure.recover(&:message) }

      it 'returns Success of evaluation of the block against the error' do
        is_expected.to eq(Fear.success('error'))
      end
    end

    context 'block fails' do
      subject(:recover) { failure.recover { raise 'unexpected error' } }

      it { is_expected.to be_kind_of(described_class) }
      it { expect { recover.get }.to raise_error(RuntimeError, 'unexpected error') }
    end
  end

  describe '#to_either' do
    subject { failure.to_either }
    it { is_expected.to eq(Fear.left(exception)) }
  end

  describe '#===' do
    subject { match === failure }

    context 'matches erectly' do
      let(:match) { Fear.failure(exception) }
      it { is_expected.to eq(true) }
    end

    context 'value does not match' do
      let(:match) { Fear.failure(ArgumentError.new) }
      it { is_expected.to eq(false) }
    end

    context 'matches by class' do
      let(:match) { Fear.failure(RuntimeError) }
      it { is_expected.to eq(true) }
    end

    context 'does not matches by class' do
      let(:match) { Fear.failure(ArgumentError) }
      it { is_expected.to eq(false) }
    end
  end

  describe '#match' do
    context 'matched' do
      subject do
        failure.match do |m|
          m.failure(->(x) { x.message.length < 2 }) { |x| "Error: #{x}" }
          m.failure(->(x) { x.message.length > 2 }) { |x| "Error: #{x}" }
          m.success(->(x) { x.length > 2 }) { |x| "Success: #{x}" }
        end
      end

      it { is_expected.to eq('Error: error') }
    end

    context 'nothing matched and no else given' do
      subject do
        proc do
          failure.match do |m|
            m.failure(->(x) { x.message.length < 2 }) { |x| "Error: #{x}" }
            m.success { 'noop' }
          end
        end
      end

      it { is_expected.to raise_error(Fear::MatchError) }
    end

    context 'nothing matched and else given' do
      subject do
        failure.match do |m|
          m.failure(->(x) { x.message.length < 2 }) { |x| "Error: #{x}" }
          m.else { :default }
        end
      end

      it { is_expected.to eq(:default) }
    end
  end

  describe '#to_s' do
    subject { failure.to_s }

    it { is_expected.to eq('#<Fear::Failure exception=#<RuntimeError: error>>') }
  end
end
