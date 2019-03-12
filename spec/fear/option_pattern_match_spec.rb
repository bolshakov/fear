RSpec.describe Fear::OptionPatternMatch do
  context 'Some' do
    let(:matcher) do
      described_class.new do |m|
        m.some(:even?) { |x| "#{x} is even" }
        m.some(:odd?) { |x| "#{x} is odd" }
      end
    end

    it do
      expect(matcher.call(Fear.some(4))).to eq('4 is even')
      expect(matcher.call(Fear.some(3))).to eq('3 is odd')
      expect do
        matcher.call(Fear.none)
      end.to raise_error(Fear::MatchError)
    end
  end

  context 'None' do
    let(:matcher) do
      described_class.new do |m|
        m.none { 'nil' }
      end
    end

    it do
      expect(matcher.call(Fear.none)).to eq('nil')
      expect do
        matcher.call(Fear.some(3))
      end.to raise_error(Fear::MatchError)
    end
  end
end
