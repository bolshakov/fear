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

  specify '#get_or_else returns default value' do
    default = 13
    val = failure.get_or_else(default)

    expect(val).to eq default
  end

  specify '#or_else returns default' do
    default = Try { 13 }
    val = failure.or_else(default)

    expect(val).to eq default
  end

  specify '#or_else fail if default is not Try' do
    default = 13

    expect do
      failure.or_else(default)
    end.to raise_error(ArgumentError, 'default should be Try')
  end

  specify '#to_option returns None' do
    option = failure.to_option
    expect(option).to be_kind_of(None)
  end
end
