RSpec.describe Fear::Some do
  include Fear::Option::Mixin

  it_behaves_like Fear::RightBiased::Right do
    let(:right) { Some('value') }
  end

  subject(:some) { Some(42) }

  describe '#select' do
    subject { some.select(&predicate) }

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

  describe '#get' do
    subject { some.get }
    it { is_expected.to eq(42) }
  end

  describe '#or_nil' do
    subject { some.or_nil }
    it { is_expected.to eq(42) }
  end

  describe '#empty?' do
    subject { some.empty? }
    it { is_expected.to eq(false) }
  end
end
