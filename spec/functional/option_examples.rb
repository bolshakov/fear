RSpec.shared_examples Functional::Option do
  specify '#get_or_else raises exception is no block given' do
    expect do
      described_class.new.get_or_else
    end.to raise_error(ArgumentError)
  end

  specify '#map raises exception is no block given' do
    expect do
      described_class.new.map
    end.to raise_error(ArgumentError)
  end

  specify '#inject raises exception is no block given' do
    expect do
      described_class.new.inject(32)
    end.to raise_error(ArgumentError)
  end

  specify '#select raises exception is no block given' do
    expect do
      described_class.new.select
    end.to raise_error(ArgumentError)
  end

  specify '#reject raises exception is no block given' do
    expect do
      described_class.new.reject
    end.to raise_error(ArgumentError)
  end
end
