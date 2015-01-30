include Functional

RSpec.describe Option do
  describe 'Option()' do
    it 'returns Some if value is not nil' do
      option = Option(double)

      expect(option).to be_kind_of(Some)
    end

    it 'returns None if value is nil' do
      option = Option(nil)

      expect(option).to be_kind_of(None)
    end
  end
end
