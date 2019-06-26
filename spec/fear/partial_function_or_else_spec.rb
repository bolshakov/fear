# typed: false
RSpec.describe Fear::PartialFunction, '#or_else' do
  subject(:first_or_else_second) { first.or_else(second) }

  let(:first) { Fear.case(->(x) { x.even? }) { |x| "first: #{x}" } }
  let(:second) { Fear.case(->(x) { x % 3 == 0 }) { |x| "second: #{x}" } }

  describe '#defined_at?' do
    context 'first defined, second not' do
      subject { first_or_else_second.defined_at?(4) }

      it { is_expected.to eq(true) }
    end

    context 'first not defined, second defined' do
      subject { first_or_else_second.defined_at?(9) }

      it { is_expected.to eq(true) }
    end

    context 'first not defined, second not defined' do
      subject { first_or_else_second.defined_at?(5) }

      it { is_expected.to eq(false) }
    end

    context 'first and second defined' do
      subject { first_or_else_second.defined_at?(6) }

      it { is_expected.to eq(true) }
    end
  end

  describe '#call' do
    context 'first defined, second not' do
      subject { first_or_else_second.call(4) }

      it { is_expected.to eq('first: 4') }
    end

    context 'first not defined, second defined' do
      subject { first_or_else_second.call(9) }

      it { is_expected.to eq('second: 9') }
    end

    context 'first not defined, second not defined' do
      subject { -> { first_or_else_second.call(5) } }

      it { is_expected.to raise_error(Fear::MatchError, 'partial function not defined at: 5') }
    end

    context 'first and second defined' do
      subject { first_or_else_second.call(6) }

      it { is_expected.to eq('first: 6') }
    end
  end

  describe '#call_or_else' do
    let(:fallback) { ->(x) { "fallback: #{x}" } }

    context 'first defined, second not' do
      subject { first_or_else_second.call_or_else(4, &fallback) }

      it { is_expected.to eq('first: 4') }
    end

    context 'first not defined, second defined' do
      subject { first_or_else_second.call_or_else(9, &fallback) }

      it { is_expected.to eq('second: 9') }
    end

    context 'first not defined, second not defined' do
      subject { first_or_else_second.call_or_else(5, &fallback) }

      it { is_expected.to eq('fallback: 5') }
    end

    context 'first and second defined' do
      subject { first_or_else_second.call_or_else(6, &fallback) }

      it { is_expected.to eq('first: 6') }
    end
  end

  describe '#or_else' do
    let(:first_or_else_second_or_else_third) { first_or_else_second.or_else(third) }
    let(:third) { Fear.case(->(x) { x % 7 == 0 }) { |x| "third: #{x}" } }

    describe '#defined_at?' do
      context 'first defined, second not' do
        subject { first_or_else_second_or_else_third.defined_at?(4) }

        it { is_expected.to eq(true) }
      end

      context 'first not defined, second defined' do
        subject { first_or_else_second_or_else_third.defined_at?(9) }

        it { is_expected.to eq(true) }
      end

      context 'first not defined, second not defined, third defined' do
        subject { first_or_else_second_or_else_third.defined_at?(7) }

        it { is_expected.to eq(true) }
      end

      context 'first not defined, second not defined, third not defined' do
        subject { first_or_else_second_or_else_third.defined_at?(1) }

        it { is_expected.to eq(false) }
      end

      context 'first, second and third defined' do
        subject { first_or_else_second.defined_at?(42) }

        it { is_expected.to eq(true) }
      end
    end

    describe '#call' do
      context 'first defined, second not' do
        subject { first_or_else_second_or_else_third.call(4) }

        it { is_expected.to eq('first: 4') }
      end

      context 'first not defined, second defined' do
        subject { first_or_else_second_or_else_third.call(9) }

        it { is_expected.to eq('second: 9') }
      end

      context 'first not defined, second not defined, third defined' do
        subject { first_or_else_second_or_else_third.call(7) }

        it { is_expected.to eq('third: 7') }
      end

      context 'first not defined, second not defined, third not defined' do
        subject { -> { first_or_else_second_or_else_third.call(1) } }

        it { is_expected.to raise_error(Fear::MatchError, 'partial function not defined at: 1') }
      end

      context 'first, second and third defined' do
        subject { first_or_else_second.call(42) }

        it { is_expected.to eq('first: 42') }
      end
    end

    describe '#call_or_else' do
      let(:fallback) { ->(x) { "fallback: #{x}" } }

      context 'first defined, second not' do
        subject { first_or_else_second_or_else_third.call_or_else(4, &fallback) }

        it { is_expected.to eq('first: 4') }
      end

      context 'first not defined, second defined' do
        subject { first_or_else_second_or_else_third.call_or_else(9, &fallback) }

        it { is_expected.to eq('second: 9') }
      end

      context 'first not defined, second not defined, third defined' do
        subject { first_or_else_second_or_else_third.call_or_else(7, &fallback) }

        it { is_expected.to eq('third: 7') }
      end

      context 'first not defined, second not defined, third not defined' do
        subject { first_or_else_second_or_else_third.call_or_else(1, &fallback) }

        it { is_expected.to eq('fallback: 1') }
      end

      context 'first, second and third defined' do
        subject { first_or_else_second_or_else_third.call_or_else(42, &fallback) }

        it { is_expected.to eq('first: 42') }
      end
    end
  end

  describe '#and_then' do
    let(:first_or_else_second_and_then_function) { first_or_else_second.and_then(&function) }
    let(:function) { ->(x) { "f: #{x}" } }

    describe '#defined_at?' do
      context 'first defined, second not' do
        subject { first_or_else_second_and_then_function.defined_at?(2) }

        it { is_expected.to eq(true) }
      end

      context 'first not defined, second defined' do
        subject { first_or_else_second_and_then_function.defined_at?(3) }

        it { is_expected.to eq(true) }
      end

      context 'first not defined, second not defined' do
        subject { first_or_else_second_and_then_function.defined_at?(5) }

        it { is_expected.to eq(false) }
      end

      context 'first defined, second defined' do
        subject { first_or_else_second_and_then_function.defined_at?(6) }

        it { is_expected.to eq(true) }
      end
    end

    describe '#call' do
      context 'first defined, second not' do
        subject { first_or_else_second_and_then_function.call(2) }

        it { is_expected.to eq('f: first: 2') }
      end

      context 'first not defined, second defined' do
        subject { first_or_else_second_and_then_function.call(3) }

        it { is_expected.to eq('f: second: 3') }
      end

      context 'first not defined, second not defined' do
        subject { -> { first_or_else_second_and_then_function.call(5) } }

        it { is_expected.to raise_error(Fear::MatchError, 'partial function not defined at: 5') }
      end

      context 'first defined, second defined' do
        subject { first_or_else_second_and_then_function.call(6) }

        it { is_expected.to eq('f: first: 6') }
      end
    end

    describe '#call_or_else' do
      let(:fallback) { ->(x) { "fallback: #{x}" } }

      context 'first defined, second not' do
        subject { first_or_else_second_and_then_function.call_or_else(2, &fallback) }

        it { is_expected.to eq('f: first: 2') }
      end

      context 'first not defined, second defined' do
        subject { first_or_else_second_and_then_function.call_or_else(3, &fallback) }

        it { is_expected.to eq('f: second: 3') }
      end

      context 'first not defined, second not defined' do
        subject { first_or_else_second_and_then_function.call_or_else(5, &fallback) }

        it { is_expected.to eq('fallback: 5') }
      end

      context 'first defined, second defined' do
        subject { first_or_else_second_and_then_function.call_or_else(6, &fallback) }

        it { is_expected.to eq('f: first: 6') }
      end
    end
  end
end
