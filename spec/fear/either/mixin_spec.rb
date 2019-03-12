RSpec.describe Fear::Either::Mixin do
  include Fear::Either::Mixin

  describe 'Left()' do
    subject { Left(42) }

    it { is_expected.to eq(Fear::Left.new(42)) }
  end

  describe 'Right()' do
    subject { Right(42) }

    it { is_expected.to eq(Fear::Right.new(42)) }
  end
end
