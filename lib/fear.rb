# frozen_string_literal: true

require "fear/utils"
require "fear/right_biased"
require "fear/struct"
require "fear/unit"
require "fear/either_api"
require "fear/for_api"
require "fear/future_api"
require "fear/option_api"
require "fear/pattern_matching_api"
require "fear/try_api"
require "fear/version"

module Fear
  Error = Class.new(StandardError)
  public_constant :Error

  IllegalStateException = Class.new(Error)
  public_constant :IllegalStateException

  MatchError = Class.new(Error)
  public_constant :MatchError

  NoSuchElementError = Class.new(Error)
  public_constant :NoSuchElementError

  PatternSyntaxError = Class.new(Error)
  public_constant :PatternSyntaxError

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
