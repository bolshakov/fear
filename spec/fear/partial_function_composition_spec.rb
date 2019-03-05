require 'any'
# This file contains tests from
# https://github.com/scala/scala/blob/2.13.x/test/junit/scala/PartialFunctionCompositionTest.scala
RSpec.describe Fear::PartialFunction do
  include Fear::PartialFunction::Mixin

  let(:fallback_fun) { ->(_) { 'fallback' } }
  let(:pass_all) { PartialFunction(Any) { |x| x } }
  let(:pass_short) { PartialFunction(->(x) { x.length < 5 }) { |x| x } }
  let(:pass_pass) { PartialFunction(->(x) { x.include?('pass') }) { |x| x } }

  let(:all_and_then_short) { pass_all & pass_short }
  let(:short_and_then_all) { pass_short & pass_all }
  let(:all_and_then_pass) { pass_all & pass_pass }
  let(:pass_and_then_all) { pass_pass & pass_all }
  let(:pass_and_then_short) { pass_pass & pass_short }
  let(:short_and_then_pass) { pass_short & pass_pass }

  it '#and_then' do
    expect(all_and_then_short.call_or_else('pass', &fallback_fun)).to eq('pass')
    expect(short_and_then_all.call_or_else('pass', &fallback_fun)).to eq('pass')
    expect(all_and_then_short.defined_at?('pass')).to eq(true)
    expect(short_and_then_all.defined_at?('pass')).to eq(true)

    expect(all_and_then_pass.call_or_else('pass', &fallback_fun)).to eq('pass')
    expect(pass_and_then_all.call_or_else('pass', &fallback_fun)).to eq('pass')
    expect(all_and_then_pass.defined_at?('pass')).to eq(true)
    expect(pass_and_then_all.defined_at?('pass')).to eq(true)

    expect(all_and_then_pass.call_or_else('longpass', &fallback_fun)).to eq('longpass')
    expect(pass_and_then_all.call_or_else('longpass', &fallback_fun)).to eq('longpass')
    expect(all_and_then_pass.defined_at?('longpass')).to eq(true)
    expect(pass_and_then_all.defined_at?('longpass')).to eq(true)

    expect(all_and_then_short.call_or_else('longpass', &fallback_fun)).to eq('fallback')
    expect(short_and_then_all.call_or_else('longpass', &fallback_fun)).to eq('fallback')
    expect(all_and_then_short.defined_at?('longpass')).to eq(false)
    expect(short_and_then_all.defined_at?('longpass')).to eq(false)

    expect(all_and_then_pass.call_or_else('longstr', &fallback_fun)).to eq('fallback')
    expect(pass_and_then_all.call_or_else('longstr', &fallback_fun)).to eq('fallback')
    expect(all_and_then_pass.defined_at?('longstr')).to eq(false)
    expect(pass_and_then_all.defined_at?('longstr')).to eq(false)

    expect(pass_and_then_short.call_or_else('pass', &fallback_fun)).to eq('pass')
    expect(short_and_then_pass.call_or_else('pass', &fallback_fun)).to eq('pass')
    expect(pass_and_then_short.defined_at?('pass')).to eq(true)
    expect(short_and_then_pass.defined_at?('pass')).to eq(true)

    expect(pass_and_then_short.call_or_else('longpass', &fallback_fun)).to eq('fallback')
    expect(short_and_then_pass.call_or_else('longpass', &fallback_fun)).to eq('fallback')
    expect(pass_and_then_short.defined_at?('longpass')).to eq(false)
    expect(short_and_then_pass.defined_at?('longpass')).to eq(false)

    expect(short_and_then_pass.call_or_else('longstr', &fallback_fun)).to eq('fallback')
    expect(pass_and_then_short.call_or_else('longstr', &fallback_fun)).to eq('fallback')
    expect(short_and_then_pass.defined_at?('longstr')).to eq(false)
    expect(pass_and_then_short.defined_at?('longstr')).to eq(false)
  end
end
