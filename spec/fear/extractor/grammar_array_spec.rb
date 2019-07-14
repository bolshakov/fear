# frozen_string_literal: true

RSpec.describe Fear::Extractor::Grammar, "Array" do
  let(:parser) { Fear::Extractor::GrammarParser.new }
  let(:matcher) { parser.parse(pattern).to_matcher }

  context "non empty array" do
    let(:pattern) { "[1, 2, 3, 4]" }

    it do
      first = matcher.head
      rest_after_first = matcher.tail

      expect(first).to be_kind_of(Fear::Extractor::ArrayHeadMatcher)
      expect(first.matcher.value).to eq(1)
      expect(rest_after_first).to be_kind_of(Fear::Extractor::ArrayMatcher)

      second = rest_after_first.head
      rest_after_second = rest_after_first.tail
      expect(second).to be_kind_of(Fear::Extractor::ArrayHeadMatcher)
      expect(second.matcher.value).to eq(2)
      expect(rest_after_second).to be_kind_of(Fear::Extractor::ArrayMatcher)
    end
  end
end
