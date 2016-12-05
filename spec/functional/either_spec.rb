RSpec.describe Functional::Either do
  include Functional

  describe '#left?' do
    context 'Left' do
      subject { Left('error') }
      it { is_expected.to be_left }
    end

    context 'Right' do
      subject { Right('result') }
      it { is_expected.not_to be_left }
    end
  end

  describe '#right?' do
    context 'Left' do
      subject { Left('error') }
      it { is_expected.not_to be_right }
    end

    context 'Right' do
      subject { Right('result') }
      it { is_expected.to be_right }
    end
  end

  describe '#reduce' do
    subject do
      either.reduce(
        ->(left) { "Failure: #{left}" },
        ->(right) { "Success: #{right}" },
      )
    end

    context 'Left' do
      let(:either) { Left('error') }
      it { is_expected.to eq('Failure: error') }
    end

    context 'Right' do
      let(:either) { Right('result') }
      it { is_expected.to eq('Success: result') }
    end
  end

  describe '#swop' do
    subject { either.swap }

    context 'Left' do
      let(:either) { Left('error') }
      it { is_expected.to eq(Right('error')) }
    end

    context 'Right' do
      let(:either) { Right('error') }
      it { is_expected.to eq(Left('error')) }
    end
  end

  describe '#join_right' do
    subject(:join_right) { either.join_right }

    context 'Left', 'is Either' do
      let(:either) { Left(Left('error')) }
      it { is_expected.to eq(either) }
    end

    context 'Left', 'is not Either' do
      let(:either) { Left('error') }
      it { is_expected.to eq(either) }
    end

    context 'Right', 'is Either' do
      let(:either) { Right(Left('error')) }
      it { is_expected.to eq(Left('error')) }
    end

    context 'Right', 'is not Either' do
      subject { proc { join_right } }
      let(:either) { Right('result') }
      it { is_expected.to raise_error(TypeError) }
    end
  end

  describe '#join_left' do
    subject(:join_left) { either.join_left }

    context 'Left', 'is Either' do
      let(:either) { Left(Left('error')) }
      it { is_expected.to eq(Left('error')) }
    end

    context 'Left', 'is not Either' do
      subject { proc { join_left } }
      let(:either) { Left('error') }
      it { is_expected.to raise_error(TypeError) }
    end

    context 'Right', 'is Either' do
      let(:either) { Right(Left('error')) }
      it { is_expected.to eq(either) }
    end

    context 'Right', 'is not Either' do
      let(:either) { Right('result') }
      it { is_expected.to eq(either) }
    end
  end

  describe '#each' do
    subject do
      proc do |block|
        expect(either.each(&block)).to be_kind_of(described_class)
      end
    end

    context 'Left' do
      let(:either) { Left('error') }
      it { is_expected.not_to yield_control }
    end

    context 'Right' do
      let(:either) { Right('result') }
      it { is_expected.to yield_with_args('result') }
    end
  end

  describe '#get_or_else', 'with block' do
    subject { either.get_or_else { 'default' } }

    context 'Left' do
      let(:either) { Left('error') }
      it { is_expected.to eq('default') }
    end

    context 'Right' do
      let(:either) { Right('result') }
      it { is_expected.to eq('result') }
    end
  end

  describe '#get_or_else', 'with default argument' do
    subject { either.get_or_else('default') }

    context 'Left' do
      let(:either) { Left('error') }
      it { is_expected.to eq('default') }
    end

    context 'Right' do
      let(:either) { Right('result') }
      it { is_expected.to eq('result') }
    end
  end

  describe '#include?' do
    context 'Left' do
      subject { Left('value') }
      it { is_expected.not_to include('value') }
    end

    context 'Right', 'contains value' do
      subject { Right('value') }
      it { is_expected.to include('value') }
    end

    context 'Right', 'does not contain value' do
      subject { Right('another value') }
      it { is_expected.not_to include('value') }
    end
  end

  describe '#all?' do
    context 'Left' do
      subject { Left(5).all?(&:even?) }
      it { is_expected.to eq(true) }
    end

    context 'Right', 'matches predicate' do
      subject { Right(5).all?(&:odd?) }
      it { is_expected.to eq(true) }
    end

    context 'Right', 'does not match predicate' do
      subject { Right(5).all?(&:even?) }
      it { is_expected.to eq(false) }
    end
  end

  describe '#any?' do
    context 'Left' do
      subject { Left(5).any?(&:even?) }
      it { is_expected.to eq(false) }
    end

    context 'Right', 'matches predicate' do
      subject { Right(5).any?(&:odd?) }
      it { is_expected.to eq(true) }
    end

    context 'Right', 'does not match predicate' do
      subject { Right(5).any?(&:even?) }
      it { is_expected.to eq(false) }
    end
  end

  describe '#flat_map' do
    subject { either.flat_map { |e| Right("Result: #{e}") } }

    context 'Left' do
      let(:either) { Left('error') }
      it { is_expected.to eq(either) }
    end

    context 'Right' do
      let(:either) { Right('result') }
      it { is_expected.to eq(Right('Result: result')) }
    end
  end

  describe '#map' do
    subject { either.map { |r| "Result: #{r}" } }

    context 'Right' do
      let(:either) { Right('result') }
      it { is_expected.to eq(Right('Result: result')) }
    end

    context 'Left' do
      let(:either) { Left('error') }
      it { is_expected.to eq(either) }
    end
  end

  describe '#detect' do
    subject { either.detect(default) { |v| v > 10 } }

    context 'Left', 'default is a value' do
      let(:either) { Left(12) }
      let(:default) { -1 }

      it { is_expected.to eq(Left(-1)) }
    end

    context 'Left', 'default is a proc' do
      let(:either) { Left(12) }
      let(:default) { proc { -1 } }

      it { is_expected.to eq(Left(-1)) }
    end

    context 'Right', 'matches the predicate' do
      let(:either) { Right(12) }
      let(:default) { -1 }

      it { is_expected.to eq(either) }
    end

    context 'Right', 'does not match the predicate and default is a value' do
      let(:either) { Right(7) }
      let(:default) { -1 }

      it { is_expected.to eq(Left(-1)) }
    end

    context 'Right', 'does not match the predicate and default is a proc' do
      let(:either) { Right(7) }
      let(:default) { proc { -1 } }

      it { is_expected.to eq(Left(-1)) }
    end
  end

  describe '#to_a' do
    subject { either.to_a }

    context 'Left' do
      let(:either) { Left('error') }
      it { is_expected.to eq([]) }
    end

    context 'Right' do
      let(:either) { Right('result') }
      it { is_expected.to eq(['result']) }
    end
  end

  describe '#to_option' do
    subject { either.to_option }

    context 'Left' do
      let(:either) { Left('error') }

      it { is_expected.to eq(None()) }
    end

    context 'Right' do
      let(:either) { Right('result') }

      it { is_expected.to eq(Some('result')) }
    end
  end
end
