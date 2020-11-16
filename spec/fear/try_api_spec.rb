# frozen_string_literal: true

RSpec.describe Fear::TryApi do
  describe "Fear.try" do
    context "when success" do
      subject { Fear.try { 42 } }

      it { is_expected.to be_success_of(42) }
    end

    context "when failure" do
      subject { Fear.try { raise RuntimeError } }

      it { is_expected.to be_failure_of(RuntimeError) }
    end

    context "when low level error happened" do
      subject(:try) { Fear.try { raise Exception } }

      it { expect { try }.to raise_error(Exception) }
    end
  end
end
