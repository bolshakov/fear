RSpec.describe Fear::Extractor::Pattern do
  describe '.new' do
    context 'invalid syntax' do
      subject { -> { described_class.new('[1, 2, 3') } }

      it { is_expected.to raise_error(Fear::PatternSyntaxError, <<-MSG) }
Expected one of [0-9], [\\s], ',', '+', '-', ']' at line 1, column 9 (byte 9):
[1, 2, 3
~~~~~~~~^
      MSG
    end
  end
end
