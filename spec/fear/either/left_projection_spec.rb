# frozen_string_literal: true

RSpec.describe Fear::Either::LeftProjection do
  subject(:projection) { described_class.new(either) }

  describe "#include?" do
    context "on Fear::Right" do
      let(:either) { Fear.right("value") }

      it { is_expected.not_to include("value") }
    end

    context "on Fear::Left" do
      let(:either) { Fear.left("value") }

      it { is_expected.to include("value") }
      it { is_expected.not_to include("another values") }
    end
  end

  describe "#get_or_else" do
    context "on Fear::Right" do
      let(:either) { Fear.right("value") }

      context "with block" do
        subject { projection.get_or_else { "default" } }

        it "returns default value" do
          is_expected.to eq("default")
        end
      end

      context "with default argument" do
        subject { projection.get_or_else("default") }

        it "returns default value" do
          is_expected.to eq("default")
        end
      end

      context "with false argument" do
        subject { projection.get_or_else(false) }

        it "returns default value" do
          is_expected.to eq(false)
        end
      end

      context "with nil argument" do
        subject { projection.get_or_else(nil) }

        it "returns default value" do
          is_expected.to eq(nil)
        end
      end
    end

    context "on Fear::Left" do
      let(:either) { Fear.left("value") }

      context "with block" do
        subject { projection.get_or_else { "default" } }

        it "returns value" do
          is_expected.to eq("value")
        end
      end

      context "with default argument" do
        subject { projection.get_or_else("default") }

        it "returns value" do
          is_expected.to eq("value")
        end
      end

      context "with false argument" do
        subject { projection.get_or_else(false) }

        it "returns value" do
          is_expected.to eq("value")
        end
      end

      context "with nil argument" do
        subject { projection.get_or_else(nil) }

        it "returns value" do
          is_expected.to eq("value")
        end
      end
    end
  end

  describe "#each" do
    context "on Fear::Right" do
      let(:either) { Fear.right(42) }

      it "does not yield control and returns either" do
        expect do |block|
          expect(projection.each(&block)).to eq(either)
        end.not_to yield_control
      end
    end

    context "on Fear::Left" do
      let(:either) { Fear.left(42) }

      it "yields block and return either" do
        expect do |block|
          expect(projection.each(&block)).to eq(either)
        end.to yield_with_args(42)
      end
    end
  end

  describe "#map" do
    subject { projection.map(&:length) }

    context "on Fear::Right" do
      let(:either) { Fear.right("value") }

      it "returns self" do
        is_expected.to eq(either)
      end
    end

    context "on Fear::Left" do
      let(:either) { Fear.left("value") }

      it "perform transformation" do
        is_expected.to be_left_of(5)
      end
    end
  end

  describe "#flat_map" do
    context "on Fear::Right" do
      subject { projection.flat_map { Fear.right(_1 * 2) } }

      let(:either) { Fear.right("value") }

      it "returns self" do
        is_expected.to eq(either)
      end
    end

    context "on Fear::Left" do
      subject(:either) { Fear.left(21) }

      context "block returns neither left, nor right" do
        subject { proc { projection.flat_map { 42 } } }

        it "fails with TypeError" do
          is_expected.to raise_error(TypeError)
        end
      end

      context "block returns Right" do
        subject { projection.flat_map { |e| Fear.right(e * 2) } }

        it "maps to block result" do
          is_expected.to be_right_of(42)
        end
      end

      context "block returns Left" do
        subject { projection.flat_map { |e| Fear.left(e * 2) } }

        it "maps to block result" do
          is_expected.to be_left_of(42)
        end
      end
    end
  end

  describe "#to_option" do
    subject { projection.to_option }

    context "on Fear::Right" do
      let(:either) { Fear.right("value") }

      it { is_expected.to be_none }
    end

    context "on Fear::Left" do
      let(:either) { Fear.left("value") }

      it { is_expected.to be_some_of("value") }
    end
  end

  describe "#to_a" do
    subject { projection.to_a }

    context "on Fear::Right" do
      let(:either) { Fear.right("value") }

      it { is_expected.to eq([]) }
    end

    context "on Fear::Left" do
      let(:either) { Fear.left("value") }

      it { is_expected.to eq(["value"]) }
    end
  end

  describe "#any?" do
    subject { projection.any?(&predicate) }

    context "on Fear::Right" do
      let(:predicate) { ->(v) { v == "value" } }
      let(:either) { Fear.right("value") }

      it { is_expected.to eq(false) }
    end

    context "on Fear::Left" do
      let(:either) { Fear.left("value") }

      context "matches predicate" do
        let(:predicate) { ->(v) { v == "value" } }

        it { is_expected.to eq(true) }
      end

      context "does not match predicate" do
        let(:predicate) { ->(v) { v != "value" } }

        it { is_expected.to eq(false) }
      end
    end
  end

  describe "select" do
    subject { projection.select(&predicate) }

    context "on Fear::Right" do
      let(:either) { Fear.right("value") }
      let(:predicate) { ->(v) { v == "value" } }

      it { is_expected.to be_right_of("value") }
    end

    context "on Fear::Left" do
      let(:either) { Fear.left("value") }

      context "predicate evaluates to true" do
        let(:predicate) { ->(v) { v == "value" } }

        it { is_expected.to be_left_of("value") }
      end

      context "predicate evaluates to false" do
        let(:predicate) { ->(v) { v != "value" } }

        it { is_expected.to be_right_of("value") }
      end
    end
  end

  describe "#find" do
    subject { projection.find(&predicate) }

    context "on Fear::Right" do
      let(:either) { Fear.right("value") }
      let(:predicate) { ->(v) { v == "value" } }

      it { is_expected.to be_none }
    end

    context "on Fear::Left" do
      let(:either) { Fear.left("value") }

      context "predicate evaluates to true" do
        let(:predicate) { ->(v) { v == "value" } }

        it { is_expected.to be_some_of(either) }
      end

      context "predicate evaluates to false" do
        let(:predicate) { ->(v) { v != "value" } }

        it { is_expected.to be_none }
      end
    end
  end
end
