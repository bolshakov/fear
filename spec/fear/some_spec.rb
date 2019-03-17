RSpec.describe Fear::Some do
  it_behaves_like Fear::RightBiased::Right do
    let(:right) { Fear.some('value') }
  end

  subject(:some) { Fear.some(42) }

  describe '#select' do
    subject { some.select(&predicate) }

    context 'predicate evaluates to true' do
      let(:predicate) { ->(v) { v > 40 } }
      it { is_expected.to eq(some) }
    end

    context 'predicate evaluates to false' do
      let(:predicate) { ->(v) { v < 40 } }
      it { is_expected.to eq(Fear.none) }
    end
  end

  describe '#reject' do
    subject { some.reject(&predicate) }

    context 'predicate evaluates to true' do
      let(:predicate) { ->(v) { v > 40 } }
      it { is_expected.to eq(Fear.none) }
    end

    context 'predicate evaluates to false' do
      let(:predicate) { ->(v) { v < 40 } }
      it { is_expected.to eq(some) }
    end
  end

  describe '#get' do
    subject { some.get }
    it { is_expected.to eq(42) }
  end

  describe '#or_nil' do
    subject { some.or_nil }
    it { is_expected.to eq(42) }
  end

  describe '#empty?' do
    subject { some.empty? }
    it { is_expected.to eq(false) }
  end

  describe '#match' do
    context 'matched' do
      subject do
        some.match do |m|
          m.some(->(x) { x > 2 }) { |x| x * 2 }
          m.none { 'noop' }
        end
      end

      it { is_expected.to eq(84) }
    end

    context 'nothing matched and no else given' do
      subject do
        proc do
          some.match do |m|
            m.some(->(x) { x < 2 }) { |x| x * 2 }
            m.none { 'noop' }
          end
        end
      end

      it { is_expected.to raise_error(Fear::MatchError) }
    end

    context 'nothing matched and else given' do
      subject do
        some.match do |m|
          m.none { |x| x * 2 }
          m.else { :default }
        end
      end

      it { is_expected.to eq(:default) }
    end
  end

  describe '#to_s' do
    subject { some.to_s }

    it { is_expected.to eq('#<Fear::Some get=42>') }
  end

  describe 'pattern matching' do
    subject { Fear.xcase('Some(v : Integer)') { |v:| "matched #{v}" }.call_or_else(var) { 'nothing' } }

    context 'some of int' do
      let(:var) { Fear.some(42) }

      it { is_expected.to eq('matched 42') }
    end

    context 'some of string' do
      let(:var) { Fear.some('42') }

      it { is_expected.to eq('nothing') }
    end

    context 'not some' do
      let(:var) { '42' }

      it { is_expected.to eq('nothing') }
    end
  end
end
