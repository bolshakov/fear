RSpec.describe Fear::Extractor::Pattern do
  describe '.new' do
    context 'invalid syntax' do
      subject { -> { described_class.new('[1, 2, 3') } }

      it 'shows where the error happens' do
        is_expected.to raise_error(Fear::PatternSyntaxError) { |error|
          lines = error.message.split("\n")
          expect(lines[0]).to start_with('Expected one of')
            .and(end_with('at line 1, column 9 (byte 9):'))

          expect(lines[1]).to eq('[1, 2, 3')
          expect(lines[2]).to eq('~~~~~~~~^')
        }
      end
    end
  end

  describe '#failure_reason' do
    let(:pattern) { described_class.new('Some([:err, 444])') }

    context 'not defined' do
      subject { pattern.failure_reason(Fear.some([:err, 445])) }

      it { is_expected.to eq(<<-MSG.strip) }
Expected `445` to match:
Some([:err, 444])
~~~~~~~~~~~~^
      MSG
    end
  end
end
