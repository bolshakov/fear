RSpec.describe Fear::None do
  include Fear::Option::Mixin

  it_behaves_like Fear::RightBiased::Left do
    let(:left) { None() }
  end

  subject(:none) { None() }

  describe '#get' do
    subject { proc { none.get } }
    it { is_expected.to raise_error(Fear::NoSuchElementError) }
  end

  describe '#or_nil' do
    subject { none.or_nil }
    it { is_expected.to eq(nil) }
  end

  describe '#or_else' do
    subject { none.or_else { alternative } }
    let(:alternative) { Some(42) }

    it 'returns alternative' do
      is_expected.to eq(alternative)
    end
  end

  describe '#empty?' do
    subject { none.empty? }
    it { is_expected.to eq(true) }
  end

  describe '#select' do
    subject { none.select { |value| value > 42 } }

    it 'always return None' do
      is_expected.to eq(None())
    end
  end

  describe '#reject' do
    subject { none.reject { |value| value > 42 } }

    it 'always return None' do
      is_expected.to eq(None())
    end
  end
end
