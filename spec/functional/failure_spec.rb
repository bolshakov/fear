include Functional

RSpec.describe Failure do
  TestError = Class.new(StandardError)
  let(:error) { TestError }

  subject(:failure) { Failure(error) }

  specify '#get fail with exception' do
    expect do
      failure.get
    end.to raise_error(error)
  end
end
