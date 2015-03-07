include Functional

RSpec.describe Future do
  let(:value) { 5 }
  let(:error) { StandardError.new('something went wrong') }

  def future(&block)
    Future(executor: Concurrent::ImmediateExecutor.new, &block)
  end

  def await(&block)
    result = block.call
    sleep 0.1
    result
  end

  context '#on_complete' do
    it 'run callback with value' do
      expect do |callback|
        await do
          Future { value }.on_complete(&callback)
        end
      end.to yield_with_args(Success(value))
    end

    it 'run callback with error' do
      expect do |callback|
        await do
          Future { fail error }.on_complete(&callback)
        end
      end.to yield_with_args(Failure(error))
    end
  end

  context '#on_success' do
    it 'run callback if no error' do
      expect do |callback|
        await do
          Future { value }.on_success(&callback)
        end
      end.to yield_with_args(value)
    end

    it 'do not run callback if error occured' do
      expect do |callback|
        await do
          Future { fail error }.on_success(&callback)
        end
      end.not_to yield_with_args
    end
  end

  context '#on_failure' do
    it 'do not run callback if no error' do
      expect do |callback|
        await do
          Future { value }.on_failure(&callback)
        end
      end.not_to yield_with_args
    end

    it 'run callback if error occured' do
      expect do |callback|
        await do
          Future { fail error }.on_failure(&callback)
        end
      end.to yield_with_args(error)
    end
  end

  context '#completed?' do
    it 'completed with value' do
      future = await do
        Future { value }
      end
      expect(future).to be_completed
    end

    it 'completed with error' do
      future = await do
        Future { fail error }
      end
      expect(future).to be_completed
    end

    it 'not completed with value' do
      future =
        Future do
          sleep 1
          value
        end
      expect(future).not_to be_completed
    end

    it 'not completed with error' do
      future =
        Future do
          sleep 1
          fail error
        end

      expect(future).not_to be_completed
    end
  end

  context '#value' do
    it 'None if not completed' do
      future =
        Future do
          sleep 1
          value
        end

      future_value = future.value

      expect(future_value).to be_kind_of(None)
    end

    it 'Some of Success if completed with result' do
      future = await do
        Future { value }
      end

      future_value = future.value

      expect(future_value).to be == Some(Success(value))
    end

    it 'Some of Failure if completed with error' do
      future = await do
        Future { fail error }
      end

      future_value = future.value

      expect(future_value).to eq Some(Failure(error))
    end
  end

  context '.failed' do
    it 'returns already failed Future' do
      future = Future.failed(error)

      future_value = future.value

      expect(future_value).to eq Some(Failure(error))
    end
  end

  context '#transform' do
    let(:failure) { ->(e) { e.message } }
    let(:success) { ->(v) { v*2 } }

    it 'call first callback if successfull' do
      transformed_future = Future(executor: Concurrent::ImmediateExecutor.new) do
        value
      end.transform(success, failure)

      future_value = transformed_future.value

      expect(future_value).to eq Some(Success(10))
    end

    it 'call second callback if failed' do
      transformed_future = Future(executor: Concurrent::ImmediateExecutor.new) do
        fail error
      end.transform(success, failure)

      future_value = transformed_future.value

      expect(future_value).to eq Some(Failure('something went wrong'))
    end
  end

  context '#map' do
    it 'successfull result' do
      result = future { value }.map { |r| r * 2 }.value

      expect(result).to eq Some(Success(10))
    end

    it 'failed result' do
      result = future { fail error }.map { |r| r * 2 }.value

      expect(result).to eq Some(Failure(error))
    end
  end

  context '#select' do
    it 'satisfy predicate' do
      value = future { 2 }.select(&:even?).value

      expect(value).to eq Some(Success(2))
    end

    it 'does not satisfy predicate' do
      value = future { 3}.select(&:even?).value

      expect(value.get.exception).to be_kind_of(Functional::Future::NoSuchElementException)
    end

    it 'failure' do
      value = future { fail error }.select(&:even?).value

      expect(value.get.exception).to eq error
    end
  end

  context '#recover' do
    it 'success' do
      value = future { 2/1 }.recover { 0 }.value

      expect(value).to eq Some(Success(2))
    end

    it 'failure' do
      value = future { 2/0 }.recover do |error|
        case error
        when ZeroDivisionError
          0
        else
          42
        end
      end.value

      expect(value).to eq Some(Success(0))
    end
  end

  context '#zip' do
    it 'success' do
      this = future { 1 }
      that = future { 2 }

      value = this.zip(that).value

      expect(value).to eq Some(Success([1, 2]))
    end

    it 'self fails' do
      this = future { fail error }
      that = future { 2 }

      value = this.zip(that).value

      expect(value).to eq Some(Failure(error))
    end

    it 'other fails' do
      this = future { 1 }
      that = future { fail error }

      value = this.zip(that).value

      expect(value).to eq Some(Failure(error))
    end

    it 'both fail' do
      this = future { fail error }
      that = future { fail ArgumentError }

      value = this.zip(that).value

      expect(value).to eq Some(Failure(error))
    end
  end

  context '#fallback_to' do
    it 'success' do
      fallback = future { 42 }
      value = future { 2 }.fallback_to(fallback).value

      expect(value).to eq Some(Success(2))
    end

    it 'failure' do
      fallback = future { 42 }
      value = future { fail error }.fallback_to(fallback).value

      expect(value).to eq Some(Success(42))
    end

    it 'failure with failed fallback' do
      fallback = future { fail ArumentError }
      value = future { fail error }.fallback_to(fallback).value

      expect(value).to eq Some(Failure(error))
    end
  end

  context '#and_then' do
    context 'single callback' do
      context 'callback is called' do
        it 'returns result of future' do
          expect do |callback|
            future { 5 }.and_then(&callback)
          end.to yield_with_args(Success(5))
        end
      end

      context 'future with Success' do
        it 'ensure callback is called' do
          expect do |callback|
            future { 5 }.and_then(&callback)
          end.to yield_with_args(Success(5))
        end

        context 'callback is not failing' do
          it 'returns result of future' do
            value = future { 5 }.and_then { }.value

            expect(value).to eq Some(Success(5))
          end
        end

        context 'callback is failing' do
          it 'returns result of future' do
            value = future { 5 }.and_then { fail error }.value

            expect(value).to eq Some(Success(5))
          end
        end
      end

      context 'future with Failure' do
        it 'ensure callback is called' do
          expect do |callback|
            future { fail error }.and_then(&callback)
          end.to yield_with_args(Failure(error))
        end

        context 'callback is not failing' do
          it 'returns result of future' do
            value = future { fail error }.and_then { }.value

            expect(value).to eq Some(Failure(error))
          end
        end

        context 'callback is failing' do
          it 'returns result of future' do
            value = future { fail error }.and_then { fail ArgumentError }.value

            expect(value).to eq Some(Failure(error))
          end
        end
      end
    end

    context 'multiple callbacks' do
      context 'on Future with Success' do
        it 'ensure callbacks are called' do
          expect do |first|
            expect do |second|
              future { 5 }.and_then(&first).and_then(&second)
            end.to yield_with_args(Success(5))
          end.to yield_with_args(Success(5))
        end

        it 'ensure callbacks called in specified order' do
          # REVIEW: could not write failing test
          last_called = nil
          Future { 5 }.and_then do
            sleep 1
            expect(last_called).to eq(nil)
            last_called = :first
          end.and_then do
            expect(last_called).to eq(:first), 'second callback called before first'
            last_called = :second
          end

          sleep 2

          expect(last_called).to eq(:second)
        end

        context 'first callback is not failing' do
          context 'and second callback is not failing' do
            it 'returns result of the Future' do
              value = future { 5 }.and_then { }.and_then { }.value

              expect(value).to eq Some(Success(5))
            end
          end

          context 'and second callback is failing' do
            it 'returns result of the Future' do
              value = future { 5 }.and_then { }.and_then { fail ArgumentError }.value

              expect(value).to eq Some(Success(5))
            end
          end
        end

        context 'first callback is failing' do
          it 'calls second callback' do
            expect do |callback|
              future { 5 }.and_then { fail error }.and_then(&callback)
            end.to yield_with_args(Success(5))
          end

          context 'and second callback is not failing' do
            it 'returns result of the Future' do
              value = future { 5 }.and_then { fail error }.and_then { }.value

              expect(value).to eq Some(Success(5))
            end
          end

          context 'and second callback is failing' do
            it 'returns result of the Future' do
              value = future { 5 }.and_then { fail error }.and_then { fail ArgumentError }.value

              expect(value).to eq Some(Success(5))
            end
          end
        end
      end
    end
  end

  context '.successful' do
    it 'returns already succeed Future' do
      future = Future.successful(value)

      future_value = future.value

      expect(future_value).to eq Some(Success(value))
    end
  end
end
