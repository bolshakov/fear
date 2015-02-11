include Functional

RSpec.describe Success do
  let(:value) { 42 }

  subject(:success) { Success(value) }

  specify '#get returns value' do
    val = success.get
    expect(val).to eq value
  end
end
