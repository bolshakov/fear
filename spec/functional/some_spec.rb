include Functional

RSpec.describe Some do
  it_behaves_like 'Option'

  let(:value) { 42 }

  subject(:some) { Some(value) }

  it 'is not empty' do
    expect(some).not_to be_empty
  end

  it 'is present' do
    expect(some).to be_present
  end

  specify '#get returns value' do
    expect(some.get).to eq value
  end

  specify '#get_or_else returns value' do
    result = some.get_or_else(42)

    expect(result).to eq value
  end

  specify '#or_nil returns value' do
    result = some.or_nil

    expect(result).to eq value
  end

  specify '#map returns Some with block applied to the value' do
    result = some.map { |value| value + 42 }

    expect(result).to eq Some(84)
  end

  specify '#inject returns result of block evaluation' do
    result = some.inject(13) { |value| value + 42}

    expect(result).to eq 84
  end

  specify '#select returns self if predicate evaluates to true' do
    result = some.select { |value| value > 40}

    expect(result).to eq some
  end

  specify '#select returns None if predicate evaluates to false' do
    result = some.select { |value| value < 40}

    expect(result).to eq None()
  end

  specify '#reject returns self if predicate evaluates to false' do
    result = some.reject { |value| value < 40 }

    expect(result).to eq some
  end

  specify '#reject returns None if predicate evaluates to true' do
    result = some.reject { |value| value > 40}

    expect(result).to eq None()
  end
end
