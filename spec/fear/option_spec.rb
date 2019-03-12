RSpec.describe Fear::Option do
  describe '#Fear.option()' do
    context 'value is nil' do
      subject { Fear.option(nil) }
      it { is_expected.to eq(Fear.none) }
    end

    context 'value is not nil' do
      subject { Fear.option(42) }
      it { is_expected.to eq(Fear.some(42)) }
    end
  end
end
