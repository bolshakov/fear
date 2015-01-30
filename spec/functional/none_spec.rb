include Functional

RSpec.describe None do
  it 'is empty' do
    none = None()

    expect(none).to be_empty
  end

  it 'is not defined' do
    none = None()

    expect(none).not_to be_defined
  end
end
