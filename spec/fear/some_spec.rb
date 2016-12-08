RSpec.describe Fear::Some do
  include Fear::Option::Mixin

  it_behaves_like Fear::RightBiased::Right do
    let(:right) { described_class.new('value') }
  end

  subject(:some) { Some(value) }
  let(:value) { 42 }

  describe '#detect' do
    subject { some.detect(&predicate) }

    context 'predicate evaluates to true' do
      let(:predicate) { ->(v) { v > 40 } }
      it { is_expected.to eq(some) }
    end

    context 'predicate evaluates to false' do
      let(:predicate) { ->(v) { v < 40 } }
      it { is_expected.to eq(None()) }
    end
  end

  describe '#reject' do
    subject { some.reject(&predicate) }

    context 'predicate evaluates to true' do
      let(:predicate) { ->(v) { v > 40 } }
      it { is_expected.to eq(None()) }
    end

    context 'predicate evaluates to false' do
      let(:predicate) { ->(v) { v < 40 } }
      it { is_expected.to eq(some) }
    end
  end

  specify '#get returns value' do
    expect(some.get).to eq value
  end

  specify '#or_nil returns value' do
    result = some.or_nil

    expect(result).to eq value
  end
end
