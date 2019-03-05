RSpec.describe Fear::PartialFunction, '#and_then' do
  include Fear::PartialFunction::Mixin

  context 'proc' do
    subject(:pf_and_f) { partial_function.and_then(&function) }

    let(:partial_function) { PartialFunction(->(x) { x.even? }) { |x| "pf: #{x}" } }
    let(:function) { ->(x) { "f: #{x}" } }

    describe '#defined_at?' do
      context 'defined' do
        subject { pf_and_f.defined_at?(4) }

        it { is_expected.to eq(true) }
      end

      context 'not defined' do
        subject { pf_and_f.defined_at?(3) }

        it { is_expected.to eq(false) }
      end
    end

    describe '#call' do
      context 'defined' do
        subject { pf_and_f.call(4) }

        it { is_expected.to eq('f: pf: 4') }
      end

      context 'not defined' do
        subject { -> { pf_and_f.call(3) } }

        it { is_expected.to raise_error(Fear::MatchError, 'partial function not defined at: 3') }
      end
    end

    describe '#call_or_else' do
      let(:fallback) { ->(x) { "fallback: #{x}" } }

      context 'defined' do
        subject { pf_and_f.call_or_else(4, &fallback) }

        it { is_expected.to eq('f: pf: 4') }
      end

      context 'not defined' do
        subject { pf_and_f.call_or_else(3, &fallback) }

        it { is_expected.to eq('fallback: 3') }
      end
    end
  end

  context 'partial function' do
    subject(:first_and_then_second) { first.and_then(second) }

    describe '#defined_at?' do
      context 'first defined, second defined on result of first' do
        subject { first_and_then_second.defined_at?(6) }

        let(:first) { PartialFunction(->(x) { x.even? }) { |x| x / 2 } }
        let(:second) { PartialFunction(->(x) { x % 3 == 0 }) { |x| x / 3 } }

        it { is_expected.to eq(true) }
      end

      context 'first defined, second not defined on result of first' do
        subject { first_and_then_second.defined_at?(4) }

        let(:first) { PartialFunction(->(x) { x.even? }) { |x| x / 2 } }
        let(:second) { PartialFunction(->(x) { x % 3 == 0 }) { |x| x / 3 } }

        it { is_expected.to eq(false) }
      end

      context 'first not defined' do
        subject { first_and_then_second.defined_at?(3) }

        let(:first) { PartialFunction(->(x) { x.even? }) { |x| "first: #{x}" } }
        let(:second) { PartialFunction(->(x) { x % 3 == 0 }) { |x| "second: #{x}" } }

        it { is_expected.to eq(false) }
      end
    end

    describe '#call' do
      context 'first defined, second defined on result of first' do
        subject { first_and_then_second.call(6) }

        let(:first) { PartialFunction(->(x) { x.even? }) { |x| x / 2 } }
        let(:second) { PartialFunction(->(x) { x % 3 == 0 }) { |x| x / 3 } }

        it { is_expected.to eq(1) }
      end

      context 'first defined, second not defined on result of first' do
        subject { -> { first_and_then_second.call(4) } }

        let(:first) { PartialFunction(->(x) { x.even? }) { |x| x / 2 } }
        let(:second) { PartialFunction(->(x) { x % 3 == 0 }) { |x| x / 3 } }

        it { is_expected.to raise_error(Fear::MatchError, 'partial function not defined at: 2') }
      end

      context 'first not defined' do
        subject { -> { first_and_then_second.call(3) } }

        let(:first) { PartialFunction(->(x) { x.even? }) { |x| "first: #{x}" } }
        let(:second) { PartialFunction(->(x) { x % 3 == 0 }) { |x| "second: #{x}" } }

        it { is_expected.to raise_error(Fear::MatchError, 'partial function not defined at: 3') }
      end
    end

    describe '#call_or_else' do
      let(:fallback) { ->(x) { "fallback: #{x}" } }

      context 'first defined, second defined on result of first' do
        subject { first_and_then_second.call_or_else(6, &fallback) }

        let(:first) { PartialFunction(->(x) { x.even? }) { |x| x / 2 } }
        let(:second) { PartialFunction(->(x) { x % 3 == 0 }) { |x| x / 3 } }

        it { is_expected.to eq(1) }
      end

      context 'first defined, second not defined on result of first' do
        subject { first_and_then_second.call_or_else(4, &fallback) }

        let(:first) { PartialFunction(->(x) { x.even? }) { |x| x / 2 } }
        let(:second) { PartialFunction(->(x) { x % 3 == 0 }) { |x| x / 3 } }

        it { is_expected.to eq('fallback: 4') }
      end

      context 'first not defined' do
        subject { first_and_then_second.call_or_else(3, &fallback) }

        let(:first) { PartialFunction(->(x) { x.even? }) { |x| "first: #{x}" } }
        let(:second) { PartialFunction(->(x) { x % 3 == 0 }) { |x| "second: #{x}" } }

        it { is_expected.to eq('fallback: 3') }
      end
    end
  end
end
