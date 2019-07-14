# frozen_string_literal: true

RSpec.describe Fear::Future do
  context "#on_complete" do
    it "run callback with value" do
      expect do |callback|
        Fear::Future.successful(5).on_complete(&callback)
      end.to yield_with_args(Fear.success(5))
    end

    let(:error) { StandardError.new }

    it "run callback with error" do
      expect do |callback|
        Fear::Future.failed(error).on_complete(&callback)
      end.to yield_with_args(Fear.failure(error))
    end
  end

  context "#on_complete_match" do
    context "successful covered" do
      subject do
        proc do |callback|
          Fear::Future.successful(5).on_complete_match do |m|
            m.success(&callback)
          end
        end
      end

      it { is_expected.to yield_with_args(5) }
    end

    context "successful not covered" do
      subject do
        proc do |callback|
          Fear::Future.successful(5).on_complete_match do |m|
            m.failure(&callback)
          end
        end
      end

      it { is_expected.not_to yield_control }
    end

    context "failed" do
      subject do
        proc do |callback|
          Fear::Future.failed(error).on_complete_match do |m|
            m.failure(&callback)
          end
        end
      end
      let(:error) { StandardError.new }

      it { is_expected.to yield_with_args(error) }
    end

    context "failed not covered" do
      subject do
        proc do |callback|
          Fear::Future.failed(error).on_complete_match do |m|
            m.success(&callback)
          end
        end
      end
      let(:error) { StandardError.new }

      it { is_expected.not_to yield_control }
    end
  end

  shared_examples :on_success do |method_name|
    context "##{method_name}" do
      context "successful" do
        subject do
          proc do |callback|
            Fear::Future.successful(5).__send__(method_name, &callback)
          end
        end

        it { is_expected.to yield_with_args(5) }
      end

      context "failed" do
        subject do
          proc do |callback|
            Fear::Future.failed(StandardError.new).__send__(method_name, &callback)
          end
        end

        it { is_expected.not_to yield_control }
      end

      specify "call all registered callbacks" do
        expect do |second|
          expect do |first|
            Fear::Future.successful(5)
              .__send__(method_name, &first)
              .__send__(method_name, &second)
          end.to yield_with_args(5)
        end.to yield_with_args(5)
      end
    end
  end

  include_examples :on_success, :on_success
  include_examples :on_success, :each

  context "#on_success_match" do
    context "successful covered" do
      subject do
        proc do |callback|
          Fear::Future.successful(5).on_success_match do |m|
            m.case(5, &callback)
          end
        end
      end

      it { is_expected.to yield_with_args(5) }
    end

    context "successful not covered" do
      subject do
        proc do |callback|
          Fear::Future.successful(5).on_success_match do |m|
            m.case(0, &callback)
          end
        end
      end

      it { is_expected.not_to yield_control }
    end

    context "failed" do
      subject do
        proc do |callback|
          Fear::Future.failed(StandardError.new).on_success_match(&callback)
        end
      end

      it { is_expected.not_to yield_control }
    end
  end

  context "#on_failure" do
    let(:error) { StandardError.new }

    it "do not run callback if no error" do
      expect do |callback|
        Fear::Future.successful(5).on_failure(&callback)
      end.not_to yield_with_args
    end

    it "run callback if error occurred" do
      expect do |callback|
        Fear::Future.failed(error).on_failure(&callback)
      end.to yield_with_args(error)
    end

    specify "call all registered callbacks" do
      expect do |second|
        expect do |first|
          Fear::Future.failed(error)
            .on_failure(&first)
            .on_failure(&second)
        end.to yield_with_args(error)
      end.to yield_with_args(error)
    end
  end

  context "#on_failure_match" do
    context "failure covered" do
      subject do
        proc do |callback|
          Fear::Future.failed(error).on_failure_match do |m|
            m.case(StandardError, &callback)
          end
        end
      end
      let(:error) { StandardError.new }

      it { is_expected.to yield_with_args(error) }
    end

    context "failure not covered" do
      subject do
        proc do |callback|
          Fear::Future.failed(error).on_failure_match do |m|
            m.case(RuntimeError, &callback)
          end
        end
      end
      let(:error) { StandardError.new }

      it { is_expected.not_to yield_control }
    end

    context "successful" do
      subject do
        proc do |callback|
          Fear::Future.successful(5).on_failure_match(&callback)
        end
      end

      it { is_expected.not_to yield_control }
    end
  end

  context "#completed?" do
    context "not completed" do
      subject do
        Fear.future do
          sleep 0.1
          value
        end
      end

      it { is_expected.not_to be_completed }
    end

    context "completed with error" do
      subject { Fear::Await.ready(Fear.future { raise StandardError }, 1) }

      it { is_expected.to be_completed }
    end

    context "completed with value" do
      subject { Fear::Await.ready(Fear.future { 5 }, 0.5) }

      it { is_expected.to be_completed }
    end
  end

  context "#value" do
    subject { future.value }

    context "future returns nil" do
      let(:future) { Fear::Future.successful(nil) }

      it { is_expected.to eq(Fear.some(Fear.success(nil))) }
    end

    context "not completed" do
      let(:future) do
        Fear.future do
          sleep 0.1
          value
        end
      end

      it { is_expected.to eq(Fear.none) }
    end

    context "completed with success" do
      let(:future) { Fear::Future.successful(5) }

      it { is_expected.to eq(Fear.some(Fear.success(5))) }
    end

    context "completed with failure" do
      let(:future) { Fear::Future.failed(error) }
      let(:error) { StandardError.new }

      it { is_expected.to eq(Fear.some(Fear.failure(error))) }
    end
  end

  context "#transform" do
    context "successful" do
      subject { Fear::Await.result(future, 1) }

      let(:future) { Fear.future { 2 }.transform(->(v) { v * 2 }, :itself.to_proc) }

      it { is_expected.to eq(Fear.success(4)) }
    end

    context "failed" do
      subject { Fear::Await.result(future, 1) }

      let(:future) { Fear.future { raise error }.transform(:itself.to_proc, :message.to_proc) }
      let!(:error) { StandardError.new("fooo") }

      it { is_expected.to eq(Fear.failure("fooo")) }
    end
  end

  context "#map" do
    subject { Fear::Await.result(future.map { |x| x * 2 }, 1) }

    context "successful" do
      let(:future) { Fear.future { 5 } }

      it { is_expected.to eq(Fear.success(10)) }
    end

    context "failed" do
      let(:future) { Fear.future { raise error } }
      let!(:error) { StandardError.new("foo") }

      it { is_expected.to eq(Fear.failure(error)) }
    end
  end

  context "#flat_map" do
    subject { Fear::Await.result(future, 1) }

    context "successful" do
      let(:future) { Fear.future { 5 }.flat_map { |r| Fear.future { r * 2 } } }

      it { is_expected.to eq(Fear.success(10)) }
    end

    context "failed" do
      let(:future) { Fear.future { raise error }.flat_map { |r| Fear.future { r * 2 } } }
      let!(:error) { StandardError.new("foo") }

      it { is_expected.to eq(Fear.failure(error)) }
    end

    context "failed callback future" do
      let(:future) { Fear.future { 5 }.flat_map { Fear.future { raise error } } }
      let!(:error) { StandardError.new("foo") }

      it { is_expected.to eq(Fear.failure(error)) }
    end

    context "failed callback" do
      let(:future) { Fear.future { 5 }.flat_map { raise error } }
      let!(:error) { StandardError.new("foo") }

      it { is_expected.to eq(Fear.failure(error)) }
    end
  end

  context "#select" do
    context "successful and satisfies predicate" do
      subject { Fear::Await.result(future, 1) }

      let(:future) { Fear.future { 2 }.select(&:even?) }

      it { is_expected.to eq(Fear.success(2)) }
    end

    context "successful and does not satisfy predicate" do
      subject { Fear::Await.result(future, 1).exception }

      let(:future) { Fear.future { 3 }.select(&:even?) }

      it { is_expected.to be_kind_of(Fear::NoSuchElementError) }
    end

    context "failure" do
      subject { Fear::Await.result(future, 1).exception }

      let(:future) { Fear.future { raise error }.select(&:even?) }
      let!(:error) { StandardError.new }

      it { is_expected.to eq(error) }
    end
  end

  context "#recover" do
    subject { Fear::Await.result(future, 1) }

    context "successful" do
      let(:future) do
        Fear.future { 2 }.recover do |m|
          m.case { 0 }
        end
      end

      it { is_expected.to eq(Fear.success(2)) }
    end

    context "failure and managed to recover" do
      let(:future) do
        Fear.future { 2 / 0 }.recover do |m|
          m.case(RuntimeError, &:message)
          m.case(ZeroDivisionError) { Float::INFINITY }
        end
      end

      it { is_expected.to eq(Fear.success(Float::INFINITY)) }
    end

    context "failure and error case not covered by pattern match" do
      let(:future) do
        Fear.future { 2 / 0 }.recover do |m|
          m.case(RuntimeError, &:message)
        end
      end

      it { is_expected.to match(Fear.failure(be_kind_of(ZeroDivisionError))) }
    end
  end

  context "#zip" do
    subject { Fear::Await.result(future, 1) }

    context "successful" do
      let(:future) { this.zip(that) }
      let!(:this) { Fear.future { 1 } }
      let!(:that) { Fear.future { 2 } }

      it { is_expected.to eq(Fear.success([1, 2])) }
    end

    context "first failed" do
      let(:future) { this.zip(that) }
      let!(:error) { StandardError.new }
      let!(:this) { Fear.future { raise error } }
      let!(:that) { Fear.future { 2 } }

      it { is_expected.to eq(Fear.failure(error)) }
    end

    context "second failed" do
      let(:future) { this.zip(that) }
      let!(:error) { StandardError.new }
      let!(:this) { Fear.future { 1 } }
      let!(:that) { Fear.future { raise error } }

      it { is_expected.to eq(Fear.failure(error)) }
    end
  end

  context "#fallback_to" do
    subject { Fear::Await.result(future, 1) }

    context "successful" do
      let(:future) { Fear.future { 2 }.fallback_to(fallback) }
      let!(:fallback) { Fear.future { 42 } }

      it { is_expected.to eq(Fear.success(2)) }
    end

    context "failed" do
      let(:future) { Fear.future { raise error }.fallback_to(fallback) }
      let!(:fallback) { Fear.future { 42 } }
      let!(:error) { StandardError.new }

      it { is_expected.to eq(Fear.success(42)) }
    end

    context "fallback failed" do
      let(:future) { Fear.future { raise error }.fallback_to(fallback) }
      let!(:fallback) { Fear.future { raise } }
      let!(:error) { StandardError.new }

      it { is_expected.to eq(Fear.failure(error)) }
    end
  end

  context "#and_then" do
    context "single callback" do
      context "callback is called" do
        it "calls callback" do
          expect do |callback|
            Fear::Future.successful(5).and_then do |m|
              m.success(&callback)
            end
          end.to yield_with_args(5)
        end
      end

      context "future with Success" do
        subject { Fear::Await.result(future, 1) }

        context "callback is not failing" do
          let(:future) do
            Fear.future { 5 }
              .and_then { |m| m.success { |x| x * 2 } }
          end

          it "returns the same future" do
            is_expected.to eq(Fear.success(5))
          end
        end

        context "callback is failing" do
          let(:future) { Fear.future { 5 }.and_then { |m| m.success { raise "foo" } } }

          it { is_expected.to eq(Fear.success(5)) }
        end
      end

      context "future with Failure" do
        let(:error) { StandardError.new }

        it "ensure callback is called" do
          expect do |callback|
            Fear::Future.failed(error).and_then do |m|
              m.failure(&callback)
            end
          end.to yield_with_args(error)
        end

        context "callback is not failing" do
          subject { Fear::Await.result(future, 1) }

          let(:future) { Fear.future { raise error }.and_then {} }
          let!(:error) { StandardError.new }

          it "returns result of future" do
            is_expected.to eq(Fear.failure(error))
          end
        end

        context "callback is failing" do
          subject { Fear::Await.result(future, 1) }

          let(:future) do
            Fear.future { raise error }
              .and_then { raise ArgumentError }
          end
          let!(:error) { StandardError.new }

          it "returns result of future" do
            is_expected.to eq(Fear.failure(error))
          end
        end
      end
    end

    context "multiple callbacks" do
      context "on Future with Success" do
        it "ensure callbacks are called" do
          expect do |first|
            expect do |second|
              Fear::Future.successful(5)
                .and_then { |m| m.success(&first) }
                .and_then { |m| m.success(&second) }
            end.to yield_with_args(5)
          end.to yield_with_args(5)
        end

        it "ensure callbacks called in specified order" do
          # REVIEW: could not write failing test
          last_called = nil
          Fear.future { 5 }.and_then do
            sleep 1
            expect(last_called).to eq(nil)
            last_called = :first
          end.and_then do
            expect(last_called).to(
              eq(:first), "second callback called before first"
            )
            last_called = :second
          end

          sleep 2

          expect(last_called).to eq(:second)
        end

        context "first callback is not failing" do
          context "and second callback is not failing" do
            subject { Fear::Await.result(future, 1) }

            let(:future) do
              Fear.future { 5 }
                .and_then {}
                .and_then {}
            end

            it { is_expected.to eq(Fear.success(5)) }
          end

          context "and second callback is failing" do
            subject { Fear::Await.result(future, 1) }

            let(:future) do
              Fear.future { 5 }
                .and_then {}
                .and_then { raise }
            end

            it { is_expected.to eq(Fear.success(5)) }
          end
        end

        context "first callback is failing" do
          it "calls second callback" do
            expect do |callback|
              Fear::Future.successful(5).and_then { raise error }.and_then { |m| m.success(&callback) }
            end.to yield_with_args(5)
          end

          context "and second callback is not failing" do
            subject { Fear::Await.result(future, 1) }

            let(:future) do
              Fear.future { 5 }
                .and_then { raise }
                .and_then {}
            end

            it { is_expected.to eq(Fear.success(5)) }
          end

          context "and second callback is failing" do
            subject { Fear::Await.result(future, 1) }

            let(:future) do
              Fear.future { 5 }
                .and_then { raise }
                .and_then { raise ArgumentError }
            end

            it { is_expected.to eq(Fear.success(5)) }
          end
        end
      end
    end
  end

  context ".successful" do
    it "returns already succeed Future" do
      future = described_class.successful(5)

      future_value = future.value

      expect(future_value).to eq Fear.some(Fear.success(5))
    end
  end

  context ".failed" do
    let(:error) { StandardError.new }

    it "returns already failed Future" do
      value = described_class.failed(error).value

      expect(value).to eq Fear.some(Fear.failure(error))
    end
  end

  describe Fear::Awaitable do
    describe "#result" do
      context "managed to complete within timeout" do
        subject { Fear::Await.result(Fear.future { 5 }, 0.01) }

        it { is_expected.to eq(Fear.success(5)) }
      end

      context "managed to complete within timeout with error" do
        subject { Fear::Await.result(Fear.future { raise error }, 0.01) }

        let!(:error) { StandardError.new }

        it { is_expected.to eq(Fear.failure(error)) }
      end

      context "did not manage to complete within timeout" do
        subject do
          proc do
            Fear::Await.result(Fear.future { sleep(1) }, 0.01)
          end
        end

        it { is_expected.to raise_error(Timeout::Error) }
      end
    end

    describe "#ready" do
      context "managed to complete within timeout" do
        subject { Fear::Await.ready(Fear.future { 5 }, 0.01).value }

        it { is_expected.to eq(Fear.some(Fear.success(5))) }
      end

      context "did not manage to complete within timeout" do
        subject do
          proc do
            Fear::Await.ready(Fear.future { sleep(1) }, 0.01)
          end
        end

        it { is_expected.to raise_error(Timeout::Error) }
      end
    end
  end
end
