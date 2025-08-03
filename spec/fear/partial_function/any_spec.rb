# frozen_string_literal: true

RSpec.describe Fear::PartialFunction::Any do
  subject(:any) { described_class }

  describe ".===" do
    it { expect(any === 42).to eq(true) }
    it { expect(any === "foo").to eq(true) }
    it { expect(any === Object.new).to eq(true) }
  end

  describe ".==" do
    it { expect(any == 42).to eq(true) }
    it { expect(any == "foo").to eq(true) }
    it { expect(any == Object.new).to eq(true) }
  end

  describe ".to_proc" do
    subject(:any_proc) { any.to_proc }

    it { expect(any_proc.call(42)).to eq(true) }
    it { expect(any_proc.call("foo")).to eq(true) }
    it { expect(any_proc.call(Object.new)).to eq(true) }
  end
end
