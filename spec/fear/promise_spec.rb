# frozen_string_literal: true

require "fear/promise"

RSpec.describe Fear::Promise do
  let(:value) { 42 }
  let(:error) { StandardError.new("something went wrong") }

  def not_completed_promise
    Fear::Promise.new(executor: Concurrent::ImmediateExecutor.new)
  end

  context "not completed" do
    it "#success! returns self" do
      completed_promise = not_completed_promise.success!(value)

      expect(completed_promise).to eq completed_promise
    end

    it "#success returns true" do
      completed = not_completed_promise.success(value)

      expect(completed).to be true
    end

    it "#failure! returns self" do
      completed_promise = not_completed_promise.failure!(error)

      expect(completed_promise).to eq completed_promise
    end

    it "#failure returns true" do
      completed = not_completed_promise.failure(error)

      expect(completed).to be true
    end

    it "#completed? returns true" do
      expect(not_completed_promise).not_to be_completed
    end

    it "#future returns not completed future" do
      future = not_completed_promise.to_future

      expect(future).not_to be_completed
    end
  end

  context "completed" do
    def completed_promise
      not_completed_promise.success!(value)
    end

    it "#success! fails with exception" do
      expect do
        completed_promise.success!(value)
      end.to raise_exception(Fear::IllegalStateException)
    end

    it "#success returns false" do
      completed = completed_promise.success(value)

      expect(completed).to be false
    end

    it "#failure! fails with exception" do
      expect do
        completed_promise.failure!(error)
      end.to raise_exception(Fear::IllegalStateException)
    end

    it "#failure returns false" do
      completed = completed_promise.success(error)

      expect(completed).to be false
    end

    it "#completed? returns true" do
      expect(completed_promise).to be_completed
    end

    context "#future" do
      subject(:future) { Fear::Await.ready(promise.to_future, 0.01) }

      let(:promise) { Fear::Promise.new.success!(value) }

      it "is completed" do
        expect(future).to be_completed
      end

      it "completed with value" do
        expect(future.value).to be_some_of(Fear.success(value))
      end
    end
  end
end
