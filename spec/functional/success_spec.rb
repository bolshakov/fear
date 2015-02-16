include Functional

RSpec.describe Success do
  let(:value) { 42 }

  subject(:success) { Success(value) }

  specify '#get returns value' do
    val = success.get
    expect(val).to eq value
  end

  specify '#get_or_else returns value' do
    default = 13
    val = success.get_or_else(default)

    expect(val).to eq value
  end

  specify '#or_else returns success' do
    default = Try { 13 }
    val = success.or_else(default)

    expect(val).to eq success
  end

  specify '#to_option returns Some' do
    option = success.to_option
    expect(option).to eq Some(value)
  end

  specify '#each applies given block' do
    expect do |block|
      success.each(&block)
    end.to yield_with_args(value)
  end

  specify '#flat_map returns Success if block is not failing' do
    flat_mapped_success = success.flat_map { |val| val*2 }

    expect(flat_mapped_success).to eq Success(84)
  end

  specify 'flat_map returns Failure if block is failing' do
    error = StandardError.new
    flat_mapped_success = success.flat_map { |_| fail error }

    expect(flat_mapped_success).to eq Failure(error)
  end

  specify '#select returns self is predicate holds for value' do
    selected_success = success.select { |val| val == value }

    expect(selected_success).to eq success
  end

  specify '#select returns Failure is predicate does not hold for value' do
    selected_success = success.select { |val| val != value }

    begin
      selected_success.get
    rescue => error
      expect(error.message).to eq 'Predicate does not hold for 42'
    end

    expect(selected_success).to be_kind_of(Failure)
  end
end
