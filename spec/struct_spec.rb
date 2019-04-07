RSpec.describe Fear::Struct do
  describe '.with_attributes' do
    context 'same arguments' do
      subject { struct_class.new(a: 42, b: 43) }

      let(:struct_class) { described_class.with_attributes(:a, :b) }

      it { is_expected.to have_attributes(a: 42, b: 43) }
    end

    context 'string arguments' do
      subject { -> { struct_class.new('a' => 42, 'b' => 43) } }

      let(:struct_class) { described_class.with_attributes(:a, :b) }

      it { is_expected.to raise_error(ArgumentError, 'wrong number of arguments (given 1, expected 0)') }
    end

    context 'extra argument' do
      subject { -> { struct_class.new(a: 42, b: 41, c: 43, d: 44) } }

      let(:struct_class) { described_class.with_attributes(:a, :b) }

      it { is_expected.to raise_error(ArgumentError, 'unknown keywords: c, d') }
    end

    context 'missing argument' do
      subject { -> { struct_class.new } }

      let(:struct_class) { described_class.with_attributes(:a, :b) }

      it { is_expected.to raise_error(ArgumentError, 'missing keywords: a, b') }
    end

    context 'inheritance' do
      let(:parent_struct) { described_class.with_attributes(:a, :b) }

      it 'does not change parent attributes' do
        expect do
          parent_struct.with_attributes(:c)
        end.not_to change { parent_struct.attributes }.from(%i[a b])
      end

      it 'extends parent attributes' do
        child_struct = parent_struct.with_attributes(:c)
        expect(child_struct.attributes).to eq(%i[a b c])
      end
    end

    context 'with block' do
      subject { struct_class.new(a: 42, b: 43).a_plus_b }

      let(:struct_class) do
        described_class.with_attributes(:a, :b) do
          def a_plus_b
            a + b
          end
        end
      end

      it 'evaluates block in context of struct' do
        is_expected.to eq(85)
      end
    end
  end

  describe '#==' do
    context 'with members' do
      let(:struct_class) { described_class.with_attributes(:a, :b) }

      context 'same class and members' do
        subject { struct_class.new(a: 42, b: 43) == struct_class.new(a: 42, b: 43) }

        it { is_expected.to eq(true) }
      end

      context 'same class and different members' do
        subject { struct_class.new(a: 42, b: 43) == struct_class.new(a: 42, b: 0) }

        it { is_expected.to eq(false) }
      end

      context 'different class and same members' do
        subject { struct_class.new(a: 42, b: 43) == struct_class_1.new(a: 42, b: 43) }

        let(:struct_class_1) { described_class.with_attributes(:a, :b) }

        it { is_expected.to eq(true) }
      end

      context 'different class and different members' do
        subject { struct_class.new(a: 42, b: 43) == struct_class.new(a: 42, b: 0) }

        let(:struct_class_1) { described_class.with_attributes(:a, :b) }

        it { is_expected.to eq(false) }
      end
    end
  end

  describe '#members' do
    let(:struct) { struct_class.new(b: 43, a: 42) }
    let(:struct_class) { described_class.with_attributes(:a, :b) }

    it 'returns members in the order they defined' do
      expect(struct.members).to eq(%i[a b])
    end

    it 'is immutable' do
      expect { struct.members << :c }.not_to change { struct.members }.from(%i[a b])
    end
  end

  describe '#to_a' do
    let(:struct) { struct_class.new(b: 43, a: 42) }
    let(:struct_class) { described_class.with_attributes(:a, :b) }

    it 'returns members values in the order they defined' do
      expect(struct.to_a).to eq([42, 43])
    end

    it 'is immutable' do
      expect { struct.to_a << 44 }.not_to change { struct.to_a }.from([42, 43])
    end
  end

  describe '#to_h' do
    let(:struct_class) { described_class.with_attributes(:a, :b) }

    context 'without block' do
      let(:struct) { struct_class.new(b: 43, a: 42) }

      it 'returns a Hash containing the names and values for the structs members' do
        expect(struct.to_h).to eq(a: 42, b: 43)
      end

      it 'is immutable' do
        expect { struct.to_h.merge(c: 44) }.not_to change { struct.to_h }.from(a: 42, b: 43)
      end
    end

    context 'with block' do
      subject do
        struct.to_h do |key, value|
          [key.upcase, value / 2]
        end
      end
      let(:struct) { struct_class.new(b: 2, a: 4) }

      it 'returns a Hash containing the names and values for the structs members' do
        is_expected.to eq(A: 2, B: 1)
      end
    end
  end

  describe '#copy' do
    let(:struct_class) { described_class.with_attributes(:a, :b) }
    let(:struct) { struct_class.new(b: 43, a: 42) }

    context 'attributes given' do
      subject { struct.copy(b: 44) }

      it { is_expected.to eq(struct_class.new(a: 42, b: 44)) }
    end

    context 'string attributes' do
      subject { -> { struct.copy('a' => 44) } }

      it { is_expected.to raise_error(ArgumentError, 'wrong number of arguments (given 1, expected 0)') }
    end

    context 'no attributes given' do
      subject { struct.copy == struct }

      it { is_expected.to eq(true) }
    end
  end

  describe '#inspect' do
    subject { StrInspect.new(a: 2, b: nil).inspect }
    StrInspect = Fear::Struct.with_attributes(:a, :b)

    it { is_expected.to eq('<#Fear::Struct StrInspect a=2, b=nil>') }
  end

  describe '#inspect' do
    subject { StrToS.new(a: 2, b: nil).inspect }
    StrToS = Fear::Struct.with_attributes(:a, :b)

    it { is_expected.to eq('<#Fear::Struct StrToS a=2, b=nil>') }
  end

  context 'extract' do
    Str = Fear::Struct.with_attributes(:a, :b)
    let(:struct) { Str.new(b: 43, a: 42) }

    context 'Fear::Struct subclass' do
      context 'match by one member' do
        subject do
          proc do |effect|
            struct.match do |m|
              m.xcase('Str(a, 43)', &effect)
            end
          end
        end

        it { is_expected.to yield_with_args(a: 42) }
      end

      context 'does not match' do
        subject do
          proc do |effect|
            struct.match do |m|
              m.xcase('Str(_, 40)', &effect)
              m.else {}
            end
          end
        end

        it { is_expected.not_to yield_control }
      end
    end
  end
end
