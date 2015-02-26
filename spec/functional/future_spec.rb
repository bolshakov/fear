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
      end.to yield_with_args(value)
    end

    it 'run callback with error' do
      expect do |callback|
        await do
          Future { fail error }.on_complete(&callback)
        end
      end.to yield_with_args(error)
    end
  end
end
