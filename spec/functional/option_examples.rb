RSpec.shared_examples 'Option' do
  specify '#get_or_else raises exception is no block given' do
    expect do
      subject.get_or_else
    end.to raise_error(ArgumentError)
  end

  specify '#map raises exception is no block given' do
    expect do
      subject.map
    end.to raise_error(ArgumentError)
  end

  specify '#inject raises exception is no block given' do
    expect do
      subject.inject(32)
    end.to raise_error(ArgumentError)
  end

  specify '#select raises exception is no block given' do
    expect do
      subject.select
    end.to raise_error(ArgumentError)
  end

  specify '#reject raises exception is no block given' do
    expect do
      subject.reject
    end.to raise_error(ArgumentError)
  end

  context '#==' do
    it 'Some == Some if values matches each over' do
      expect(Some(3)).to be == Some(3)
    end

    it 'Some != Some if values does not match each over' do
      expect(Some(2)).not_to be == Some(3)
    end

    it 'Some != None' do
      expect(Some(2)).not_to be == None()
    end

    it 'None == None' do
      expect(None()).to be == None()
    end
  end

  context '#eql?' do
    it 'Some to eql Some if values matches each over' do
      expect(Some(3)).to be_eql Some(3)
    end

    it 'Some not to eql Some if values does not match each over' do
      expect(Some(2)).not_to be_eql Some(3)
    end

    it 'Some not to eql None' do
      expect(Some(2)).not_to be_eql None()
    end

    it 'None to eql None' do
      expect(None()).to be_eql None()
    end
  end
end
