# frozen_string_literal: true

RSpec.describe Fear::Option::PatternMatch do
  context "Some" do
    let(:matcher) do
      described_class.new do |m|
        m.some(:even?.to_proc) { |x| "#{x} is even" }
        m.some(:odd?.to_proc) { |x| "#{x} is odd" }
      end
    end

    it do
      expect(matcher.(Fear.some(4))).to eq("4 is even")
      expect(matcher.(Fear.some(3))).to eq("3 is odd")
      expect do
        matcher.(Fear.none)
      end.to raise_error(Fear::MatchError)
    end
  end

  context "None" do
    let(:matcher) do
      described_class.new do |m|
        m.none { "nil" }
      end
    end

    it do
      expect(matcher.(Fear.none)).to eq("nil")
      expect do
        matcher.(Fear.some(3))
      end.to raise_error(Fear::MatchError)
    end
  end
end
