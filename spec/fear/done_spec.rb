RSpec.describe Fear::Done do
  describe '#to_s' do
    subject { described_class.to_s }

    it { is_expected.to eq('Done') }
  end

  describe '#inspect' do
    subject { described_class.inspect }

    it { is_expected.to eq('Done') }
  end

  describe '#==' do
    it { is_expected.to eq(described_class) }
  end
end
