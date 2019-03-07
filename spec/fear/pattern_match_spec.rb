RSpec.describe Fear::PatternMatch do
  include Fear::Option::Mixin

  context 'else at the end' do
    let(:matcher) do
      described_class.new do |m|
        m.case(Integer) { |x| "#{x} is int" }
        m.case(String) { |x| "#{x} is str" }
        m.else { |x| "#{x} is something else" }
      end
    end

    context 'Integer' do
      subject { matcher.call(4) }

      it { is_expected.to eq('4 is int') }
    end

    context 'String' do
      subject { matcher.call('4') }

      it { is_expected.to eq('4 is str') }
    end

    context 'Symbol' do
      subject { matcher.call(:a) }

      it { is_expected.to eq('a is something else') }
    end
  end

  context 'else before other branches' do
    subject { matcher.call(4) }

    let(:matcher) do
      described_class.new do |m|
        m.else { |x| "#{x} is something else" }
        m.case(Integer) { |x| "#{x} is int" }
      end
    end

    it { is_expected.to eq('4 is something else') }
  end

  context 'several else branches' do
    subject { matcher.call(4) }

    let(:matcher) do
      described_class.new do |m|
        m.else { |x| "#{x} else 1" }
        m.else { |x| "#{x} else 2" }
      end
    end

    it 'first one wins' do
      is_expected.to eq('4 else 1')
    end
  end
end
