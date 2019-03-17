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
end
