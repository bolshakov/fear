RSpec.describe Fear::EitherPatternMatch do
  include Fear::Either::Mixin

  context 'Right' do
    let(:matcher) do
      described_class.new do |m|
        m.right(:even?) { |x| "#{x} is even" }
        m.right(:odd?) { |x| "#{x} is odd" }
      end
    end

    it do
      expect(matcher.call(Right(4))).to eq('4 is even')
      expect(matcher.call(Right(3))).to eq('3 is odd')
      expect do
        matcher.call(Left(44))
      end.to raise_error(Fear::MatchError)
    end
  end

  context 'Left' do
    let(:matcher) do
      described_class.new do |m|
        m.left(:even?) { |x| "#{x} is even" }
        m.left(:odd?) { |x| "#{x} is odd" }
      end
    end

    it do
      expect(matcher.call(Left(4))).to eq('4 is even')
      expect(matcher.call(Left(3))).to eq('3 is odd')
      expect do
        matcher.call(Right(44))
      end.to raise_error(Fear::MatchError)
    end
  end
end
