RSpec.describe Fear::None do
  include Fear::Option::Mixin

  it_behaves_like Fear::RightBiased::Left do
    let(:left) { described_class.new }
  end

  subject(:none) { None() }

  specify '#get fails with exception' do
    expect do
      none.get
    end.to raise_error(NoMethodError)
  end

  specify '#or_nil returns nil' do
    result = none.or_nil

    expect(result).to eq nil
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
