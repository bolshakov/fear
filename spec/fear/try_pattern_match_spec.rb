RSpec.describe Fear::TryPatternMatch do
  include Fear::Try::Mixin

  context 'Success' do
    let(:matcher) do
      described_class.new do |m|
        m.success(:even?) { |x| "#{x} is even" }
        m.success(:odd?) { |x| "#{x} is odd" }
      end
    end

    it do
      expect(matcher.call(Success(4))).to eq('4 is even')
      expect(matcher.call(Success(3))).to eq('3 is odd')
      expect do
        matcher.call(Failure(RuntimeError.new))
      end.to raise_error(Fear::MatchError)
    end
  end

  context 'Failure' do
    let(:matcher) do
      described_class.new do |m|
        m.failure(RuntimeError) { |x| "#{x} is first" }
        m.failure(StandardError) { |x| "#{x} is second" }
      end
    end

    it do
      expect(matcher.call(Failure(RuntimeError.new))).to eq('RuntimeError is first')
      expect(matcher.call(Failure(StandardError.new))).to eq('StandardError is second')
      expect do
        matcher.call(Success(44))
      end.to raise_error(Fear::MatchError)
    end
  end
end
