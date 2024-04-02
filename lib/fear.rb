# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/dry")
loader.setup

module Fear
  Error = Class.new(StandardError)
  public_constant :Error

  IllegalStateException = Class.new(Error)
  public_constant :IllegalStateException

  MatchError = Class.new(Error)
  public_constant :MatchError

  NoSuchElementError = Class.new(Error)
  public_constant :NoSuchElementError

  extend EitherApi
  extend ForApi
  extend FutureApi
  extend OptionApi
  extend PatternMatchingApi
  extend TryApi

  module Mixin
    include Either::Mixin
    include For::Mixin
    include Option::Mixin
    include Try::Mixin
  end

  class << self
    include Mixin
  end
end
