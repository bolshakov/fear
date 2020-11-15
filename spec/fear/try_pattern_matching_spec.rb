# frozen_string_literal: true

RSpec.describe Fear::Try do
  describe "pattern matching" do
    subject do
      case value
      in Fear::Success[Integer => int]
        "success of #{int}"
      in Fear::Failure[RuntimeError]
        "runtime error"
      else
        "something else"
      end
    end

    context "when value is success of integer" do
      let(:value) { Fear.try { 42 } }

      it { is_expected.to eq("success of 42") }
    end

    context "when value is failure runtime error" do
      let(:value) { Fear.try { raise } }

      it { is_expected.to eq("runtime error") }
    end

    context "when value is something else" do
      let(:value) { Fear.try { raise StandardError } }

      it { is_expected.to eq("something else") }
    end
  end
end
