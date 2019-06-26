# typed: ignore
RSpec.describe Fear::ExtractorApi do
  def assert(value)
    expect(value).to eq(true)
  end

  def assert_not(value)
    expect(value).not_to eq(true)
  end

  def assert_invalid_syntax
    expect do
      yield
    end.to raise_error(Fear::PatternSyntaxError)
  end

  def assert_valid_syntax
    expect { yield }.not_to raise_error
  end

  specify 'Array' do
    assert(Fear['[]'] === [])
    assert_not(Fear['[]'] === [1])
    assert(Fear['[1]'] === [1])
    assert_not(Fear['[1]'] === [1, 2])
    assert_not(Fear['[1]'] === [2])
    assert(Fear['[1, 2]'] === [1, 2])
    assert_not(Fear['[1, 2]'] === [1, 3])
    assert_not(Fear['[1, 2]'] === [1, 2, 4])
    assert_not(Fear['[1, 2]'] === [1])
    assert(Fear['[*]'] === [])
    assert(Fear['[*]'] === [1, 2])
    assert_not(Fear['[1, *]'] === [])
    assert(Fear['[1, *]'] === [1])
    assert(Fear['[1, *]'] === [1, 2])
    assert(Fear['[1, *]'] === [1, 2, 3])
    assert(Fear['[[1]]'] === [[1]])
    assert(Fear['[[1],2]'] === [[1], 2])
    assert(Fear['[[1],*]'] === [[1], 2])
    assert(Fear['[[*],*]'] === [[1], 2])
    assert_invalid_syntax  { Fear['[*, 2]'] }
    assert_invalid_syntax  { Fear['[*, ]'] }
    assert_invalid_syntax  { Fear['[1, *, ]'] }
    assert_invalid_syntax  { Fear['[1, *, 2]'] }
    assert_invalid_syntax  { Fear['[1, *, *]'] }
    assert_invalid_syntax  { Fear['[*, *]'] }
    assert(Fear['[a, b]'] === [1, 2])
    assert_not(Fear['[a, b, c]'] === [1, 2])
    assert(Fear['[a, b, _]'] === [1, 2, 3])
    assert(Fear['[a, b, *c]'] === [1, 2])
    assert_not(Fear['[a, b, c, *d]'] === [1, 2])
  end

  specify 'String' do
    assert(Fear['"foo"'] === 'foo')
    assert(Fear['"f\"oo"'] === 'f"oo')
    assert_not(Fear['"foo"'] === 'bar')
    assert(Fear["'foo'"] === 'foo')
    assert_not(Fear["'foo'"] === 'bar')
  end

  specify 'Symbol' do
    assert(Fear[':"foo"'] === :foo)
    assert(Fear[":'foo'"] === :foo)
    assert(Fear[':foo'] === :foo)
    assert_not(Fear[':foo'] === :bar)
  end

  specify 'Boolean' do
    assert(Fear['true'] === true)
    assert(Fear['false'] === false)
    assert_not(Fear['true'] === false)
    assert_not(Fear['false'] === true)
  end

  specify 'Nil' do
    assert(Fear['nil'] === nil) # rubocop:disable Style/NilComparison
    assert_not(Fear['nil'] === 42)
  end

  specify '_' do
    assert(Fear['_'] === nil) # rubocop:disable Style/NilComparison
    assert(Fear['_'] === true)
    assert(Fear['_'] === false)
    assert(Fear['_'] === 42)
    assert(Fear['_'] === 'foo')
    assert(Fear['_'] === [42])
  end

  specify 'type matching' do
    class Foo
      class Bar
      end
    end

    assert(Fear['Integer'] === 3)
    assert_not(Fear['Integer'] === '3')
    assert(Fear['Numeric'] === 3)
    assert(Fear['Foo::Bar'] === Foo::Bar.new)
    assert(Fear['var : Integer'] === 3)
    assert_not(Fear['var : Integer'] === '3')
  end

  specify 'capture matcher' do
    assert(Fear['array @ [head : Integer, *tail]'] === [1, 2])
    assert_not(Fear['array @ [head : Integer, *tail]'] === ['1', 2])
  end

  specify 'extractor' do
    assert_valid_syntax { Fear['Foo(a, b : Integer)'] }
    assert(Fear['Fear::Some(a : Integer)'] === Fear.some(42))
    assert_not(Fear['Fear::Some(a : Integer)'] === Fear.some('foo'))
  end
end
