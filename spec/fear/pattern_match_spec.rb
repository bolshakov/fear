RSpec.describe Fear::PatternMatch do
  context 'extracting' do
    let(:matcher) do
      described_class.new do |m|
        m.xcase('Date(year, 2, 29)', ->(year:) { year < 2000 }) do |year:|
          "#{year} is a leap year before Millennium"
        end
        m.xcase('Date(year, 2, 29)') do |year:|
          "#{year} is a leap year after Millennium"
        end
        m.case(Date) do |date|
          "#{date.year} is not a leap year"
        end
      end
    end

    context 'before Millennium' do
      subject { matcher.call(Date.parse('1996-02-29')) }

      it { is_expected.to eq('1996 is a leap year before Millennium') }
    end

    context 'after Millennium' do
      subject { matcher.call(Date.parse('2004-02-29')) }

      it { is_expected.to eq('2004 is a leap year after Millennium') }
    end

    context 'not leap' do
      subject { matcher.call(Date.parse('2003-01-24')) }

      it { is_expected.to eq('2003 is not a leap year') }
    end
  end

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
