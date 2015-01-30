include Functional

RSpec.describe None do
  subject(:none) { None() }

  it 'is empty' do
    expect(none).to be_empty
  end

  it 'is not defined' do
    expect(none).not_to be_defined
  end

  specify '#get fails with exception' do
    expect do
      none.get
    end.to raise_error(NoMethodError, 'None#get')
  end
end
