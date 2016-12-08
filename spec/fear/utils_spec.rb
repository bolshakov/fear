RSpec.describe Fear::Utils do
  describe '.assert_arg_or_block!' do
    def assert_arg_or_block!(*args, &block)
      described_class.assert_arg_or_block!(:the_method, *args, &block)
    end

    context 'block given, argument does not given' do
      subject { proc { assert_arg_or_block! {} } }

      it { is_expected.not_to raise_error }
    end

    context 'argument given, block does not given' do
      subject { proc { assert_arg_or_block!(42) } }

      it { is_expected.not_to raise_error }
    end

    context 'argument and block given at the same time' do
      subject { proc { assert_arg_or_block!(42) {} } }

      it 'fails with argument error' do
        is_expected.to raise_error(
          ArgumentError,
          '#the_method accepts either one argument or block',
        )
      end
    end

    context 'no argument and no block given' do
      subject { proc { assert_arg_or_block! } }

      it 'fails with argument error' do
        is_expected.to raise_error(
          ArgumentError,
          '#the_method accepts either one argument or block',
        )
      end
    end
  end

  describe 'assert_type!' do
    context 'value is of the given type' do
      subject { proc { described_class.assert_type!(24, Integer) } }

      it { is_expected.not_to raise_error }
    end

    context 'value is not of the given type' do
      subject { proc { described_class.assert_type!(24, String) } }

      it 'raises TypeError' do
        is_expected.to raise_error(
          TypeError,
          'expected `24` to be of String class',
        )
      end
    end
  end
end
