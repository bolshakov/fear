include Functional

RSpec.describe Future do
  let(:value) { 5 }
  let(:error) { StandardError.new('something went wrong') }
  def await(&block)
    block.call
    sleep 0.1
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
end
