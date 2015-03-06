include Functional

RSpec.describe Future do
  let(:value) { 5 }
  let(:error) { StandardError.new('something went wrong') }

  def future(value)
    Future(executor: Concurrent::ImmediateExecutor.new) do
      if value.is_a?(StandardError)
        Failure(value)
      else
        Success(value)
      end
    end
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
      result = future(value).map { |r| r * 2 }.value

      expect(result).to eq Some(Success(10))
    end

    it 'failed result' do
      result = future(error).map { |r| r * 2 }.value

      expect(result).to eq Some(Failure(error))
    end
  end

  context '#select' do
    it 'satisfy predicate' do
      value = future(2).select(&:even?).value

      expect(value).to eq Some(Success(2))
    end

    it 'does not satisfy predicate' do
      value = future(3).select(&:even?).value

      expect(value.get.exception).to be_kind_of(Functional::Future::NoSuchElementException)
    end

    it 'failure' do
      value = future(error).select(&:even?).value

      expect(value.get.exception).to eq error
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
