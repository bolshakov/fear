# frozen_string_literal: true

RSpec.describe Fear::Try::Mixin do
  include Fear::Try::Mixin

  describe "Try()" do
    context "success" do
      subject { Try { 4 / 2 } }

      it { is_expected.to eq(Fear::Success.new(2)) }
    end

    context "failure" do
      subject { Try { 4 / 0 } }

      it { is_expected.to be_kind_of(Fear::Failure) }
    end
  end

  describe "Success()" do
    subject { Success(42) }

    it { is_expected.to be_success_of(42) }
  end

  describe "Failure()" do
    subject { Failure(error) }

    let(:error) { StandardError.new }

    it { is_expected.to be_failure_of(error) }
  end
end
