# frozen_string_literal: true

RSpec.describe Fear::For::Mixin do
  include Fear::For::Mixin

  describe "For()" do
    subject do
      For([1, 2], [2, 3], [3, 4]) do |a, b, c|
        a * b * c
      end
    end

    it { is_expected.to eq([6, 8, 9, 12, 12, 16, 18, 24]) }
  end
end
