# typed: false
RSpec.describe Fear::Unit do
  describe '#to_s' do
    subject { described_class.to_s }

    it { is_expected.to eq('#<Fear::Unit>') }
  end

  describe '#inspect' do
    subject { described_class.inspect }

    it { is_expected.to eq('#<Fear::Unit>') }
  end

  describe '#==' do
    it { is_expected.to eq(described_class) }
  end
end
