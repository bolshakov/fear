# frozen_string_literal: true

RSpec.describe Fear::EitherPatternMatch do
  context "Right" do
    let(:matcher) do
      described_class.new do |m|
        m.right(:even?.to_proc) { |x| "#{x} is even" }
        m.right(:odd?.to_proc) { |x| "#{x} is odd" }
      end
    end

    it do
      expect(matcher.(Fear.right(4))).to eq("4 is even")
      expect(matcher.(Fear.right(3))).to eq("3 is odd")
      expect do
        matcher.(Fear.left(44))
      end.to raise_error(Fear::MatchError)
    end
  end

  context "Left" do
    let(:matcher) do
      described_class.new do |m|
        m.left(:even?.to_proc) { |x| "#{x} is even" }
        m.left(:odd?.to_proc) { |x| "#{x} is odd" }
      end
    end

    it do
      expect(matcher.(Fear.left(4))).to eq("4 is even")
      expect(matcher.(Fear.left(3))).to eq("3 is odd")
      expect do
        matcher.(Fear.right(44))
      end.to raise_error(Fear::MatchError)
    end
  end
end
