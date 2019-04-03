RSpec.describe Fear::Future do
  let(:value) { 5 }
  let(:error) { StandardError.new('something went wrong') }

  def future(&block)
    described_class.new(executor: Concurrent::ImmediateExecutor.new, &block)
  end

  context '#on_complete' do
    it 'run callback with value' do
      expect do |callback|
        future { value }.on_complete(&callback)
      end.to yield_with_args(Fear.success(value))
    end

    it 'run callback with error' do
      expect do |callback|
        future { raise error }.on_complete(&callback)
      end.to yield_with_args(Fear.failure(error))
    end
  end

  context '#on_success' do
    it 'run callback if no error' do
      expect do |callback|
        future { value }.on_success(&callback)
      end.to yield_with_args(value)
    end

    it 'do not run callback if error occurred' do
      expect do |callback|
        future { raise error }.on_success(&callback)
      end.not_to yield_with_args
    end

    specify 'call all registered callbacks' do
      expect do |second|
        expect do |first|
          future { value }
            .on_success(&first)
            .on_success(&second)
        end.to yield_with_args(value)
      end.to yield_with_args(value)
    end
  end

  context '#on_failure' do
    it 'do not run callback if no error' do
      expect do |callback|
        future { value }.on_failure(&callback)
      end.not_to yield_with_args
    end

    it 'run callback if error occurred' do
      expect do |callback|
        future { raise error }.on_failure(&callback)
      end.to yield_with_args(error)
    end

    specify 'call all registered callbacks' do
      expect do |second|
        expect do |first|
          future { raise error }
            .on_failure(&first)
            .on_failure(&second)
        end.to yield_with_args(error)
      end.to yield_with_args(error)
    end
  end

  context '#completed?' do
    it 'completed with value' do
      completed_future = future { value }

      expect(completed_future).to be_completed
    end

    it 'completed with error' do
      completed_future = future { raise error }

      expect(completed_future).to be_completed
    end

    it 'not completed with value' do
      not_completed_future =
        Fear.future do
          sleep 1
          value
        end

      expect(not_completed_future).not_to be_completed
    end

    it 'not completed with error' do
      not_completed_future =
        Fear.future do
          sleep 1
          raise error
        end

      expect(not_completed_future).not_to be_completed
    end
  end

  context '#value' do
    context 'future returns nil' do
      subject { Fear::Future.successful(nil).value }

      it { is_expected.to eq(Fear.some(Fear.success(nil))) }
    end

    it 'None if not completed' do
      not_completed_future =
        Fear.future do
          sleep 0.1
          value
        end

      future_value = not_completed_future.value

      expect(future_value).to eq(Fear.none)
    end

    it 'Some of Success if completed with result' do
      future_value = future { value }.value

      expect(future_value).to eq Fear.some(Fear.success(value))
    end

    it 'Some of Failure if completed with error' do
      value = future { raise error }.value

      expect(value).to eq Fear.some(Fear.failure(error))
    end
  end

  context '#transform' do
    let(:failure) { ->(e) { e.message } }
    let(:success) { ->(v) { v * 2 } }

    it 'call first callback if successful' do
      value = future { 2 }.transform(success, failure).value

      expect(value).to eq Fear.some(Fear.success(4))
    end

    it 'call second callback if failed' do
      value = future { raise error }.transform(success, failure).value

      expect(value).to eq Fear.some(Fear.failure('something went wrong'))
    end
  end

  context '#map' do
    it 'successful result' do
      result = future { value }.map { |r| r * 2 }.value

      expect(result).to eq Fear.some(Fear.success(10))
    end

    it 'failed result' do
      result = future { raise error }.map { |r| r * 2 }.value

      expect(result).to eq Fear.some(Fear.failure(error))
    end
  end

  context '#flat_map' do
    it 'successful result' do
      result = future { value }.flat_map { |r| future { r * 2 } }.value

      expect(result).to eq Fear.some(Fear.success(10))
    end

    it 'failed result' do
      result = future { raise error }.flat_map { |r| future { r * 2 } }.value

      expect(result).to eq Fear.some(Fear.failure(error))
    end

    it 'failed callback future' do
      result = future { value }.flat_map { future { raise error } }.value

      expect(result).to eq Fear.some(Fear.failure(error))
    end

    it 'failured callback' do
      result = future { value }.flat_map { raise error }.value

      expect(result).to eq Fear.some(Fear.failure(error))
    end
  end

  context '#each' do
    it 'successful result' do
      expect do |callback|
        future { value }.each(&callback)
      end.to yield_with_args(value)
    end

    it 'failed result' do
      expect do |callback|
        future { raise error }.each(&callback)
      end.not_to yield_with_args
    end
  end

  context '#select' do
    it 'satisfy predicate' do
      value = future { 2 }.select(&:even?).value

      expect(value).to eq Fear.some(Fear.success(2))
    end

    it 'does not satisfy predicate' do
      value = future { 3 }.select(&:even?).value

      expect(value.get.exception).to be_kind_of(Fear::NoSuchElementError)
    end

    it 'failure' do
      value = future { raise error }.select(&:even?).value

      expect(value.get.exception).to eq error
    end
  end

  context '#recover' do
    it 'success' do
      value = future { 2 / 1 }.recover do |m|
        m.case { 0 }
      end.value

      expect(value).to eq Fear.some(Fear.success(2))
    end

    it 'failure and error case covered by pattern match' do
      value = future { 2 / 0 }.recover do |m|
        m.case(RuntimeError, &:message)
        m.case(ZeroDivisionError) { 0 }
      end.value

      expect(value).to eq Fear.some(Fear.success(0))
    end

    it 'failure and error case not covered by pattern match' do
      value = future { 2 / 0 }.recover do |m|
        m.case(RuntimeError, &:message)
      end.value

      expect(value.get).to be_kind_of(Fear::Failure)
      expect(value.get.exception).to be_kind_of(ZeroDivisionError)
    end
  end

  context '#zip' do
    it 'success' do
      this = future { 1 }
      that = future { 2 }

      value = this.zip(that).value

      expect(value).to eq Fear.some(Fear.success([1, 2]))
    end

    it 'self fails' do
      this = future { raise error }
      that = future { 2 }

      value = this.zip(that).value

      expect(value).to eq Fear.some(Fear.failure(error))
    end

    it 'other fails' do
      this = future { 1 }
      that = future { raise error }

      value = this.zip(that).value

      expect(value).to eq Fear.some(Fear.failure(error))
    end

    it 'both fail' do
      this = future { raise error }
      that = future { raise ArgumentError }

      value = this.zip(that).value

      expect(value).to eq Fear.some(Fear.failure(error))
    end
  end

  context '#fallback_to' do
    it 'success' do
      fallback = future { 42 }
      value = future { 2 }.fallback_to(fallback).value

      expect(value).to eq Fear.some(Fear.success(2))
    end

    it 'failure' do
      fallback = future { 42 }
      value = future { raise error }.fallback_to(fallback).value

      expect(value).to eq Fear.some(Fear.success(42))
    end

    it 'failure with failed fallback' do
      fallback = future { raise ArumentError }
      value = future { raise error }.fallback_to(fallback).value

      expect(value).to eq Fear.some(Fear.failure(error))
    end
  end

  context '#and_then' do
    context 'single callback' do
      context 'callback is called' do
        it 'returns result of future' do
          expect do |callback|
            future { 5 }.and_then do |m|
              m.success(&callback)
            end
          end.to yield_with_args(5)
        end
      end

      context 'future with Success' do
        context 'callback is not failing' do
          it 'returns result of future' do
            value = future { 5 }.and_then {}.value

            expect(value).to eq Fear.some(Fear.success(5))
          end
        end

        context 'callback is failing' do
          it 'returns result of future' do
            value = future { 5 }.and_then { raise error }.value

            expect(value).to eq Fear.some(Fear.success(5))
          end
        end
      end

      context 'future with Failure' do
        it 'ensure callback is called' do
          expect do |callback|
            future { raise error }.and_then do |m|
              m.failure(&callback)
            end
          end.to yield_with_args(error)
        end

        context 'callback is not failing' do
          it 'returns result of future' do
            value = future { raise error }.and_then {}.value

            expect(value).to eq Fear.some(Fear.failure(error))
          end
        end

        context 'callback is failing' do
          it 'returns result of future' do
            value = future { raise error }.and_then { raise ArgumentError }.value

            expect(value).to eq Fear.some(Fear.failure(error))
          end
        end
      end
    end

    context 'multiple callbacks' do
      context 'on Future with Success' do
        it 'ensure callbacks are called' do
          expect do |first|
            expect do |second|
              future { 5 }.and_then { |m| m.success(&first) }.and_then { |m| m.success(&second) }
            end.to yield_with_args(5)
          end.to yield_with_args(5)
        end

        # rubocop: disable Style/MultilineBlockChain
        it 'ensure callbacks called in specified order' do
          # REVIEW: could not write failing test
          last_called = nil
          Fear.future { 5 }.and_then do
            sleep 1
            expect(last_called).to eq(nil)
            last_called = :first
          end.and_then do
            expect(last_called).to(
              eq(:first), 'second callback called before first'
            )
            last_called = :second
          end

          sleep 2

          expect(last_called).to eq(:second)
        end
        # rubocop: enable Style/MultilineBlockChain

        context 'first callback is not failing' do
          context 'and second callback is not failing' do
            it 'returns result of the Future' do
              value = future { 5 }.and_then {}.and_then {}.value

              expect(value).to eq Fear.some(Fear.success(5))
            end
          end

          context 'and second callback is failing' do
            it 'returns result of the Future' do
              value = future { 5 }.and_then {}.and_then do
                raise ArgumentError
              end.value

              expect(value).to eq Fear.some(Fear.success(5))
            end
          end
        end

        context 'first callback is failing' do
          it 'calls second callback' do
            expect do |callback|
              future { 5 }.and_then { raise error }.and_then { |m| m.success(&callback) }
            end.to yield_with_args(5)
          end

          context 'and second callback is not failing' do
            it 'returns result of the Future' do
              value = future { 5 }.and_then { raise error }.and_then {}.value

              expect(value).to eq Fear.some(Fear.success(5))
            end
          end

          context 'and second callback is failing' do
            it 'returns result of the Future' do
              value = future { 5 }
                .and_then { raise error }
                .and_then { raise ArgumentError }
                .value

              expect(value).to eq Fear.some(Fear.success(5))
            end
          end
        end
      end
    end
  end

  context '.successful' do
    it 'returns already succeed Future' do
      future = described_class.successful(value)

      future_value = future.value

      expect(future_value).to eq Fear.some(Fear.success(value))
    end
  end

  context '.failed' do
    it 'returns already failed Future' do
      value = described_class.failed(error).value

      expect(value).to eq Fear.some(Fear.failure(error))
    end
  end

  describe Fear::Awaitable do
    describe '#result' do
      context 'managed to complete within timeout' do
        subject { Fear::Await.result(Fear.future { 5 }, 0.01) }

        it { is_expected.to eq(Fear.success(5)) }
      end

      context 'did not manage to complete within timeout' do
        subject do
          proc do
            Fear::Await.result(Fear.future { sleep(1) }, 0.01)
          end
        end

        it { is_expected.to raise_error(Timeout::Error) }
      end
    end

    describe '#ready' do
      context 'managed to complete within timeout' do
        subject { Fear::Await.ready(Fear.future { 5 }, 0.01).value }

        it { is_expected.to eq(Fear.some(Fear.success(5))) }
      end

      context 'did not manage to complete within timeout' do
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
