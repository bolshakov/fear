include Functional

RSpec.describe Failure do
  it_behaves_like Functional::RightBiased::Left do
    let(:left) { described_class.new(error) }
  end

  TestError = Class.new(StandardError)
  subject(:failure) { Failure(error) }
  let(:message) { 'something went wrong' }
  let(:error) { TestError.new(message) }

  specify '#get fail with exception' do
    expect do
      failure.get
    end.to raise_error(error)
  end

  specify '#get_or_else returns default value' do
    default = 13
    val = failure.get_or_else { default }

    expect(val).to eq default
  end

  specify '#or_else returns default' do
    default = Try { 13 }
    val = failure.or_else { default }

    expect(val).to eq default
  end

  specify '#to_option returns None' do
    option = failure.to_option

    expect(option).to be_kind_of(None)
  end

  specify '#flatten returns self' do
    flatten_failure = failure.flatten

    expect(flatten_failure).to eq failure
  end

  specify '#each do nothing' do
    expect do |block|
      failure.each(&block)
    end.not_to yield_control
  end

  specify '#select returns self' do
    selected_failure = failure.select { |value| value == 42 }

    expect(selected_failure).to eq failure
  end

  context '#recover_with' do
    specify 'returns failure if block is not failing' do
      recovered_failure = failure.recover_with(&:message)

      expect(recovered_failure).to eq Success(message)
    end

    specify 'returns Failure if block is failing' do
      error = StandardError.new
      recovered_failure = failure.recover_with { |_| fail error }

      expect(recovered_failure).to eq Failure(error)
    end

    specify 'flatten 2 levels deep Success' do
      recovered_failure = failure.recover_with do |error|
        Success(Failure(error))
      end

      expect(recovered_failure).to eq Failure(error)
    end
  end

  context '#recover' do
    specify 'returns failure if block is not failing' do
      recovered_failure = failure.recover(&:message)

      expect(recovered_failure).to eq Success(message)
    end

    specify 'returns Failure if block is failing' do
      error = StandardError.new
      recovered_failure = failure.recover { |_| fail error }

      expect(recovered_failure).to eq Failure(error)
    end
  end
end
