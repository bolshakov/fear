include Functional

RSpec.describe Some do
  it_behaves_like 'Option'

  let(:value) { double('wrapped value') }

  subject(:some) { Some(value) }

  it 'is not empty' do
    expect(some).not_to be_empty
  end

  it 'is defined' do
    expect(some).to be_defined
  end

  specify '#get returns value' do
    expect(some.get).to eq value
  end

  specify '#get_or_else does not evaluate block' do
    expect do |default|
      some.get_or_else(&default)
    end.not_to yield_control
  end

  specify '#get_or_else returns value' do
    result = some.get_or_else { 42 }

    expect(result).to eq value
  end
end
