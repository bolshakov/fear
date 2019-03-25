RSpec.describe Fear::PartialFunction::Guard do
  context 'Class' do
    context 'match' do
      subject { Fear::PartialFunction::Guard.new(Integer) === 4 }

      it { is_expected.to eq(true) }
    end

    context 'not match' do
      subject { Fear::PartialFunction::Guard.new(Integer) === '4' }

      it { is_expected.to eq(false) }
    end
  end

  context 'Symbol' do
    context 'match' do
      subject { Fear::PartialFunction::Guard.new(:even?) === :even? }

      it { is_expected.to eq(true) }
    end

    context 'not match' do
      subject { Fear::PartialFunction::Guard.new(:even?) === 4 }

      it { is_expected.to eq(false) }
    end
  end

  context 'Proc' do
    context 'match' do
      subject { Fear::PartialFunction::Guard.new(->(x) { x.even? }) === 4 }

      it { is_expected.to eq(true) }
    end

    context 'not match' do
      subject { Fear::PartialFunction::Guard.new(->(x) { x.even? }) === 3 }

      it { is_expected.to eq(false) }
    end
  end

  describe '.and' do
    context 'match' do
      subject { guard === 4 }
      let(:guard) { Fear::PartialFunction::Guard.and([Integer, :even?.to_proc, ->(x) { x.even? }]) }

      it { is_expected.to eq(true) }
    end

    context 'not match' do
      subject { guard === 3 }
      let(:guard) { Fear::PartialFunction::Guard.and([Integer, :even?.to_proc, ->(x) { x.even? }]) }

      it { is_expected.to eq(false) }
    end

    context 'empty array' do
      subject { guard === 4 }
      let(:guard) { Fear::PartialFunction::Guard.and([]) }

      it 'matches any values' do
        is_expected.to eq(true)
      end
    end

    context 'short circuit' do
      let(:guard) { Fear::PartialFunction::Guard.and([first, second, third]) }
      let(:first) { ->(_) { false } }
      let(:second) { ->(_) { raise } }
      let(:third) { ->(_) { raise } }

      it 'does not call the second and the third' do
        expect { guard === 4 }.not_to raise_error
      end
    end
  end

  describe '.or' do
    let(:guard) { Fear::PartialFunction::Guard.or(['F', Integer]) }

    context 'match second' do
      subject { guard === 4 }

      it { is_expected.to eq(true) }
    end

    context 'match first' do
      subject { guard === 'F' }

      it { is_expected.to eq(true) }
    end

    context 'not match' do
      subject { guard === 'A&' }

      it { is_expected.to eq(false) }
    end
  end
end
