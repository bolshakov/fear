# frozen_string_literal: true

RSpec.describe Fear::Struct do
  describe "pattern matching" do
    subject do
      case struct
      in Fear::Struct(a: 42)
        "a = 42"
      in Fear::Struct(a: 43, **rest)
        "a = 43, #{rest}"
      in Fear::Struct(a:)
        "a = #{a}"
      end
    end

    let(:struct_class) { described_class.with_attributes(:a, :b) }

    context "when match single value" do
      let(:struct) { struct_class.new(b: 43, a: 42) }

      it { is_expected.to eq("a = 42") }
    end

    context "when match single value and capture the rest" do
      let(:struct) { struct_class.new(b: 42, a: 43) }

      it { is_expected.to eq("a = 43, {:b=>42}") }
    end

    context "when capture a value" do
      let(:struct) { struct_class.new(b: 45, a: 44) }

      it { is_expected.to eq("a = 44") }
    end
  end
end
