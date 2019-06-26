# typed: false
RSpec.describe Fear::TryPatternMatch do
  context 'Success' do
    let(:matcher) do
      described_class.new do |m|
        m.success(:even?.to_proc) { |x| "#{x} is even" }
        m.success(:odd?.to_proc) { |x| "#{x} is odd" }
      end
    end

    it do
      expect(matcher.call(Fear.success(4))).to eq('4 is even')
      expect(matcher.call(Fear.success(3))).to eq('3 is odd')
      expect do
        matcher.call(Fear.failure(RuntimeError.new))
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
      expect(matcher.call(Fear.failure(RuntimeError.new))).to eq('RuntimeError is first')
      expect(matcher.call(Fear.failure(StandardError.new))).to eq('StandardError is second')
      expect do
        matcher.call(Fear.success(44))
      end.to raise_error(Fear::MatchError)
    end
  end
end
