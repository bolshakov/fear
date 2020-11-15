# frozen_string_literal: true

RSpec.describe Fear::PatternMatchingApi do
  describe "Fear.match" do
    subject do
      Fear.match(value) do |m|
        m.case(Integer, :even?.to_proc) { |x| "#{x} is even" }
        m.case(Integer, :odd?.to_proc) { |x| "#{x} is odd" }
        m.else { |x| "#{x} is not a number" }
      end
    end

    context "when one branch matches" do
      let(:value) { 42 }

      it { is_expected.to eq("42 is even") }
    end

    context "when another branch matches" do
      let(:value) { 21 }

      it { is_expected.to eq("21 is odd") }
    end

    context "when else matches" do
      let(:value) { "foo" }

      it { is_expected.to eq("foo is not a number") }
    end
  end
end
