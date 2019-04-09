RSpec.describe Fear::Extractor do
  describe '.register_extractor' do
    Foo = ::Struct.new(:v1, :v2)
    let(:matcher) do
      Fear.matcher do |m|
        m.case(Fear['Foo(43, second : Integer)']) { |second| "43 and #{second}" }
        m.case(Fear['Foo(42, second : Integer)']) { |second| "42 and #{second}" }
        m.else { 'no match' }
      end
    end

    let(:extractor) do
      Fear.case(Foo) { |foo| [foo.v1, foo.v2] }.lift
    end

    context 'extractor not registered' do
      it 'raise Fear::Extractor::ExtractorNotFound' do
        expect do
          described_class.find_extractor('UnknownExtractor')
        end.to raise_error(Fear::Extractor::ExtractorNotFound)
      end
    end

    context 'register by name' do
      let(:extractor) { ->(*) { Fear.some('matched') } }

      before do
        described_class.register_extractor(
          'ExtractorRegisteredByName',
          'ExtractorRegisteredByName2',
          extractor,
        )
      end

      it 'returns extractor' do
        expect(described_class.find_extractor('ExtractorRegisteredByName')).to eq(extractor)
        expect(described_class.find_extractor('ExtractorRegisteredByName2')).to eq(extractor)
      end
    end

    context 'register by class' do
      let(:extractor) { ->(*) { Fear.some('matched') } }
      ExtractorRegisteredByClass = Class.new

      before do
        described_class.register_extractor(
          ExtractorRegisteredByClass,
          'ExtractorRegisteredByClass2',
          extractor,
        )
      end

      it 'returns extractor' do
        expect(described_class.find_extractor('ExtractorRegisteredByClass')).to eq(extractor)
        expect(described_class.find_extractor('ExtractorRegisteredByClass2')).to eq(extractor)
      end
    end
  end
end
