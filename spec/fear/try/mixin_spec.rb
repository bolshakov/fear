RSpec.describe Fear::Try::Mixin do
  include Fear::Try::Mixin

  describe 'Try()' do
    context 'success' do
      subject { Try { 4 / 2 } }

      it { is_expected.to eq(Fear::Success.new(2)) }
    end

    context 'failure' do
      subject { Try { 4 / 0 } }

      it { is_expected.to be_kind_of(Fear::Failure) }
    end
  end
end
