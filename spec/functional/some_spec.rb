include Functional

RSpec.describe Some do
  it 'is not empty' do
    some = Some(double)

    expect(some).not_to be_empty
  end

  it 'is defined' do
    some = Some(double)

    expect(some).to be_defined
  end
end
