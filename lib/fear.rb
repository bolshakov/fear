require 'dry-equalizer'
require 'fear/version'
require 'fear/pattern_matching_api'

module Fear
  Error = Class.new(StandardError)
  IllegalStateException = Class.new(Error)
  NoSuchElementError = Class.new(Error)
  MatchError = Class.new(Error)
  extend PatternMatchingApi

  autoload :EmptyPartialFunction, 'fear/empty_partial_function'
  autoload :PartialFunction, 'fear/partial_function'
  autoload :PartialFunctionClass, 'fear/partial_function_class'
  autoload :PatternMatch, 'fear/pattern_match'

  autoload :Done, 'fear/done'
  autoload :For, 'fear/for'
  autoload :RightBiased, 'fear/right_biased'
  autoload :Utils, 'fear/utils'

  autoload :None, 'fear/none'
  autoload :NoneClass, 'fear/none'
  autoload :NonePatternMatch, 'fear/none_pattern_match'
  autoload :Option, 'fear/option'
  autoload :OptionPatternMatch, 'fear/option_pattern_match'
  autoload :Some, 'fear/some'
  autoload :SomePatternMatch, 'fear/some_pattern_match'

  autoload :Failure, 'fear/failure'
  autoload :FailurePatternMatch, 'fear/failure_pattern_match'
  autoload :Success, 'fear/success'
  autoload :SuccessPatternMatch, 'fear/success_pattern_match'
  autoload :Try, 'fear/try'
  autoload :TryPatternMatch, 'fear/try_pattern_match'

  autoload :Either, 'fear/either'
  autoload :EitherPatternMatch, 'fear/either_pattern_match'
  autoload :Left, 'fear/left'
  autoload :LeftPatternMatch, 'fear/left_pattern_match'
  autoload :Right, 'fear/right'
  autoload :RightPatternMatch, 'fear/right_pattern_match'

  module Mixin
    include Either::Mixin
    include For::Mixin
    include Option::Mixin
    include Try::Mixin
  end
end
