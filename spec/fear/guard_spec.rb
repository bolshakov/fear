# frozen_string_literal: true

RSpec.describe Fear::PartialFunction::Guard do
  context "Class" do
    context "match" do
      subject { Fear::PartialFunction::Guard.new(Integer) === 4 }

      it { is_expected.to eq(true) }
    end

    context "not match" do
      subject { Fear::PartialFunction::Guard.new(Integer) === "4" }

      it { is_expected.to eq(false) }
    end
  end

  context "Symbol" do
    context "match" do
      subject { Fear::PartialFunction::Guard.new(:even?) === :even? }

      it { is_expected.to eq(true) }
    end

    context "not match" do
      subject { Fear::PartialFunction::Guard.new(:even?) === 4 }

      it { is_expected.to eq(false) }
    end
  end

  context "Proc" do
    context "match" do
      subject { Fear::PartialFunction::Guard.new(->(x) { x.even? }) === 4 }

      it { is_expected.to eq(true) }
    end

    context "not match" do
      subject { Fear::PartialFunction::Guard.new(->(x) { x.even? }) === 3 }

      it { is_expected.to eq(false) }
    end
  end

  describe ".and" do
    context "match" do
      subject { guard === 4 }
      let(:guard) { Fear::PartialFunction::Guard.and([Integer, :even?.to_proc, ->(x) { x.even? }]) }

      it { is_expected.to eq(true) }
    end

    context "not match" do
      subject { guard === 3 }
      let(:guard) { Fear::PartialFunction::Guard.and([Integer, :even?.to_proc, ->(x) { x.even? }]) }

      it { is_expected.to eq(false) }
    end

    context "empty array" do
      subject { guard === 4 }
      let(:guard) { Fear::PartialFunction::Guard.and([]) }

      it "matches any values" do
        is_expected.to eq(true)
      end
    end

    context "short circuit" do
      let(:guard) { Fear::PartialFunction::Guard.and([first, second, third]) }
      let(:first) { ->(_) { false } }
      let(:second) { ->(_) { raise } }
      let(:third) { ->(_) { raise } }

      it "does not call the second and the third" do
        expect { guard === 4 }.not_to raise_error
      end
    end

    context "with many arguments" do
      let(:guard) { Fear::PartialFunction::Guard.and([guard_1, guard_2, guard_3, guard_4]) }

      let(:guard_1) { ->(x) { x % 5 == 0 } }
      let(:guard_2) { ->(x) { x % 2 == 0 } }
      let(:guard_3) { ->(x) { x % 6 == 0 } }
      let(:guard_4) { ->(x) { x % 7 == 0 } }
      let(:guard_4) { ->(x) { x % 8 == 0 } }

      it { expect(guard === 3360).to eq(true) }
      it { expect(guard === 10).to eq(false) }
      it { expect(guard === 8).to eq(false) }
      it { expect(guard === 5).to eq(false) }
      it { expect(guard === 7).to eq(false) }
      it { expect(guard === 6).to eq(false) }
      it { expect(guard === 2).to eq(false) }
    end

    describe "#and" do
      let(:guard) { guard_1_and_guard_2.and(guard_3) }
      let(:guard_1_and_guard_2) { Fear::PartialFunction::Guard.and([guard_1, guard_2]) }

      let(:guard_1) { ->(x) { x % 5 == 0 } }
      let(:guard_2) { ->(x) { x % 2 == 0 } }
      let(:guard_3) { ->(x) { x % 6 == 0 } }

      it { expect(guard === 30).to eq(true) }
      it { expect(guard === 10).to eq(false) }
      it { expect(guard === 5).to eq(false) }
      it { expect(guard === 2).to eq(false) }
      it { expect(guard === 3).to eq(false) }
    end

    describe "#and", "with three arguments" do
      let(:guard) { guard_123.and(guard_4) }
      let(:guard_123) { Fear::PartialFunction::Guard.and([guard_1, guard_2, guard_3]) }

      let(:guard_1) { ->(x) { x % 5 == 0 } }
      let(:guard_2) { ->(x) { x % 2 == 0 } }
      let(:guard_3) { ->(x) { x % 6 == 0 } }
      let(:guard_4) { ->(x) { x % 7 == 0 } }

      it { expect(guard === 420).to eq(true) }
      it { expect(guard === 10).to eq(false) }
      it { expect(guard === 5).to eq(false) }
      it { expect(guard === 7).to eq(false) }
      it { expect(guard === 6).to eq(false) }
      it { expect(guard === 2).to eq(false) }
    end

    describe "#or" do
      let(:guard) { guard_1_and_guard_2.or(guard_3) }
      let(:guard_1_and_guard_2) { Fear::PartialFunction::Guard.and([guard_1, guard_2]) }

      let(:guard_1) { ->(x) { x % 5 == 0 } }
      let(:guard_2) { ->(x) { x % 2 == 0 } }
      let(:guard_3) { ->(x) { x % 3 == 0 } }

      it { expect(guard === 10).to eq(true) }
      it { expect(guard === 3).to eq(true) }
      it { expect(guard === 5).to eq(false) }
      it { expect(guard === 2).to eq(false) }
      it { expect(guard === 7).to eq(false) }
    end

    describe "#or", "with three arguments" do
      let(:guard) { guard_123.or(guard_4) }
      let(:guard_123) { Fear::PartialFunction::Guard.and([guard_1, guard_2, guard_3]) }

      let(:guard_1) { ->(x) { x % 5 == 0 } }
      let(:guard_2) { ->(x) { x % 2 == 0 } }
      let(:guard_3) { ->(x) { x % 6 == 0 } }
      let(:guard_4) { ->(x) { x % 7 == 0 } }

      it { expect(guard === 30).to eq(true) }
      it { expect(guard === 7).to eq(true) }
      it { expect(guard === 5).to eq(false) }
      it { expect(guard === 2).to eq(false) }
      it { expect(guard === 6).to eq(false) }
    end
  end

  describe ".or" do
    let(:guard) { Fear::PartialFunction::Guard.or(["F", Integer]) }

    context "match second" do
      subject { guard === 4 }

      it { is_expected.to eq(true) }
    end

    context "match first" do
      subject { guard === "F" }

      it { is_expected.to eq(true) }
    end

    context "not match" do
      subject { guard === "A&" }

      it { is_expected.to eq(false) }
    end

    describe "#and" do
      let(:guard) { guard_1_or_guard_2.and(guard_3) }
      let(:guard_1_or_guard_2) { Fear::PartialFunction::Guard.or([guard_1, guard_2]) }

      let(:guard_1) { ->(x) { x % 5 == 0 } }
      let(:guard_2) { ->(x) { x % 2 == 0 } }
      let(:guard_3) { ->(x) { x % 3 == 0 } }

      it { expect(guard === 6).to eq(true) }
      it { expect(guard === 15).to eq(true) }
      it { expect(guard === 5).to eq(false) }
      it { expect(guard === 2).to eq(false) }
      it { expect(guard === 3).to eq(false) }
    end

    describe "#or" do
      let(:guard) { guard_1_or_guard_2.or(guard_3) }
      let(:guard_1_or_guard_2) { Fear::PartialFunction::Guard.or([guard_1, guard_2]) }

      let(:guard_1) { ->(x) { x % 5 == 0 } }
      let(:guard_2) { ->(x) { x % 2 == 0 } }
      let(:guard_3) { ->(x) { x % 3 == 0 } }

      it { expect(guard === 5).to eq(true) }
      it { expect(guard === 2).to eq(true) }
      it { expect(guard === 3).to eq(true) }
      it { expect(guard === 7).to eq(false) }
    end
  end
end
