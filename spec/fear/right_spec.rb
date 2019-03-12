RSpec.describe Fear::Right do
  it_behaves_like Fear::RightBiased::Right do
    let(:right) { Fear.right('value') }
  end

  let(:right) { Fear.right('value') }

  describe '#right?' do
    subject { right }
    it { is_expected.to be_right }
  end

  describe '#left?' do
    subject { right }
    it { is_expected.not_to be_left }
  end

  describe '#select_or_else' do
    subject { right.select_or_else(default, &predicate) }

    context 'predicate evaluates to true' do
      let(:predicate) { ->(v) { v == 'value' } }
      let(:default) { -1 }
      it { is_expected.to eq(right) }
    end

    context 'predicate evaluates to false and default is a proc' do
      let(:predicate) { ->(v) { v != 'value' } }
      let(:default) { -> { -1 } }
      it { is_expected.to eq(Fear.left(-1)) }
    end

    context 'predicate evaluates to false and default is not a proc' do
      let(:predicate) { ->(v) { v != 'value' } }
      let(:default) { -1 }
      it { is_expected.to eq(Fear.left(-1)) }
    end
  end

  describe '#select' do
    subject { right.select(&predicate) }

    context 'predicate evaluates to true' do
      let(:predicate) { ->(v) { v == 'value' } }
      it { is_expected.to eq(right) }
    end

    context 'predicate evaluates to false' do
      let(:predicate) { ->(v) { v != 'value' } }
      it { is_expected.to eq(Fear.left('value')) }
    end
  end

  describe '#reject' do
    subject { right.reject(&predicate) }

    context 'predicate evaluates to true' do
      let(:predicate) { ->(v) { v == 'value' } }
      it { is_expected.to eq(Fear.left('value')) }
    end

    context 'predicate evaluates to false' do
      let(:predicate) { ->(v) { v != 'value' } }
      it { is_expected.to eq(right) }
    end
  end

  describe '#swap' do
    subject { right.swap }
    it { is_expected.to eq(Fear.left('value')) }
  end

  describe '#reduce' do
    subject do
      right.reduce(
        ->(left) { "Left: #{left}" },
        ->(right) { "Right: #{right}" },
      )
    end

    it { is_expected.to eq('Right: value') }
  end

  describe '#join_right' do
    context 'value is Either' do
      subject { described_class.new(value).join_right }
      let(:value) { Fear.left('error') }

      it 'returns value' do
        is_expected.to eq(value)
      end
    end

    context 'value is not Either' do
      subject { proc { described_class.new('35').join_right } }

      it 'fails with type error' do
        is_expected.to raise_error(TypeError)
      end
    end
  end

  describe '#join_left' do
    context 'value is Either' do
      subject { either.join_left }
      let(:either) { described_class.new(Fear.left('error')) }

      it { is_expected.to eq(either) }
    end

    context 'value is not Either' do
      subject { either.join_left }
      let(:either) { described_class.new('result') }
      it { is_expected.to eq(either) }
    end
  end

  describe '#match' do
    context 'matched' do
      subject do
        right.match do |m|
          m.right(->(x) { x.length < 2 }) { |x| "Right: #{x}" }
          m.right(->(x) { x.length > 2 }) { |x| "Right: #{x}" }
          m.left(->(x) { x.length > 2 }) { |x| "Left: #{x}" }
        end
      end

      it { is_expected.to eq('Right: value') }
    end

    context 'nothing matched and no else given' do
      subject do
        proc do
          right.match do |m|
            m.right(->(x) { x.length < 2 }) { |x| "Right: #{x}" }
            m.left { |_| 'noop' }
          end
        end
      end

      it { is_expected.to raise_error(Fear::MatchError) }
    end

    context 'nothing matched and else given' do
      subject do
        right.match do |m|
          m.right(->(x) { x.length < 2 }) { |x| "Right: #{x}" }
          m.else { :default }
        end
      end

      it { is_expected.to eq(:default) }
    end
  end

  describe '#to_s' do
    subject { right.to_s }

    it { is_expected.to eq('#<Fear::Right value="value">') }
  end
end
