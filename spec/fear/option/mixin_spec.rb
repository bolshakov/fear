RSpec.describe Fear::Option::Mixin do
  include Fear::Option::Mixin

  describe 'Option()' do
    context 'value is nil' do
      subject { Option(nil) }

      it { is_expected.to eq(Fear.none) }
    end

    context 'value is not nil' do
      subject { Option(42) }

      it { is_expected.to eq(Fear.some(42)) }
    end
  end

  describe 'Some()' do
    context 'value is nil' do
      subject { Some(nil) }

      it { is_expected.to eq(Fear::Some.new(nil)) }
    end

    context 'value is not nil' do
      subject { Option(42) }

      it { is_expected.to eq(Fear::Some.new(42)) }
    end
  end

  describe 'None()' do
    subject { None() }

    it { is_expected.to eq(Fear::None) }
  end
end
