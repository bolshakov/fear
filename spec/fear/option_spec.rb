RSpec.describe Fear::Option do
  include Fear::Option::Mixin

  describe '#Option()' do
    context 'value is nil' do
      subject { Option(nil) }
      it { is_expected.to eq(None()) }
    end

    context 'value is not nil' do
      subject { Option(42) }
      it { is_expected.to eq(Some(42)) }
    end
  end
end
