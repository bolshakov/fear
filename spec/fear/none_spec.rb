RSpec.describe Fear::None do
  include Fear::Option::Mixin

  it_behaves_like Fear::RightBiased::Left do
    let(:left) { None() }
  end

  subject(:none) { None() }

  describe '#get' do
    subject { proc { none.get } }
    it { is_expected.to raise_error(Fear::NoSuchElementError) }
  end

  describe '#or_nil' do
    subject { none.or_nil }
    it { is_expected.to eq(nil) }
  end

  describe '#or_else' do
    subject { none.or_else { alternative } }
    let(:alternative) { Some(42) }

    it 'returns alternative' do
      is_expected.to eq(alternative)
    end
  end

  describe '#empty?' do
    subject { none.empty? }
    it { is_expected.to eq(true) }
  end

  describe '#select' do
    subject { none.select { |value| value > 42 } }

    it 'always return None' do
      is_expected.to eq(None())
    end
  end

  describe '#reject' do
    subject { none.reject { |value| value > 42 } }

    it 'always return None' do
      is_expected.to eq(None())
    end
  end

  describe '#match' do
    context 'matched' do
      subject do
        none.match do |m|
          m.some { |x| x * 2 }
          m.none { 'noop' }
        end
      end

      it { is_expected.to eq('noop') }
    end

    context 'nothing matched and no else given' do
      subject do
        proc do
          none.match do |m|
            m.some { |x| x * 2 }
          end
        end
      end

      it { is_expected.to raise_error(Fear::MatchError) }
    end

    context 'nothing matched and else given' do
      subject do
        none.match do |m|
          m.some { |x| x * 2 }
          m.else { :default }
        end
      end

      it { is_expected.to eq(:default) }
    end
  end
end
