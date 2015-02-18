include Functional

RSpec.describe None do
  it_behaves_like 'Option'

  subject(:none) { None() }

  it 'is empty' do
    expect(none).to be_empty
  end

  it 'is not present' do
    expect(none).not_to be_present
  end

  specify '#get fails with exception' do
    expect do
      none.get
    end.to raise_error(NoMethodError, 'None#get')
  end

  specify '#get_or_else devaluates block and return its value' do
    result = none.get_or_else { 42 }

    expect(result).to eq 42
  end

  specify '#or_nil returns nil' do
    result = none.or_nil

    expect(result).to eq nil
  end

  specify '#map returns None' do
    result = none.map { |value| value*42 }

    expect(result).to be_kind_of(None)
  end

  specify '#inject returns default value' do
    result = none.inject(13) { |value| value + 42}

    expect(result).to eq 13
  end

  specify '#select returns None' do
    result = none.select { |value| value > 42 }

    expect(result).to eq None()
  end

  specify '#reject returns None' do
    result = none.reject { |value| value > 42 }

    expect(result).to eq None()
  end
end
