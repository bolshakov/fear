include Functional

RSpec.describe Success do
  it_behaves_like Functional::RightBiased::Right do
    let(:right) { described_class.new('value') }
  end

  subject(:success) { Success(value) }
  let(:value) { 42 }

  specify '#get returns value' do
    val = success.get
    expect(val).to eq value
  end

  specify '#get_or_else returns value' do
    default = 13
    val = success.get_or_else { default }

    expect(val).to eq value
  end

  specify '#or_else returns success' do
    default = Try { 13 }
    val = success.or_else { Try { default } }

    expect(val).to eq success
  end

  specify '#to_option returns Some' do
    option = success.to_option

    expect(option).to eq Some(value)
  end

  context '#flatten' do
    specify 'Success of Success' do
      flatten_success = Success(success).flatten

      expect(flatten_success).to eq success
    end

    specify 'Success of Success of Success' do
      flatten_success = Success(Success(success)).flatten

      expect(flatten_success).to eq success
    end

    specify 'Success of Failure' do
      failure = Failure(StandardError.new)

      flatten_success = Success(failure).flatten

      expect(flatten_success).to eq failure
    end
  end

  specify '#each applies given block' do
    expect do |block|
      success.each(&block)
    end.to yield_with_args(value)
  end

  describe '#select' do
    subject(:selected) { success.select(&predicate) }

    context 'predicate holds for value' do
      let(:predicate) { ->(v) { v == value } }

      it { is_expected.to eq success }
    end

    context 'predicate does not hold for value' do
      let(:predicate) { ->(v) { v != value } }

      it { is_expected.to be_kind_of(Failure) }
      it { expect { selected.get }.to raise_error(RuntimeError, 'Predicate does not hold for 42') }
    end
  end

  specify '#recover_with returns self' do
    recovered_success = success.recover_with { |value| value * 2 }

    expect(recovered_success).to eq success
  end

  specify '#recover returns self' do
    recovered_success = success.recover { |value| value * 2 }

    expect(recovered_success).to eq success
  end
end
