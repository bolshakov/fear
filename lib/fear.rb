# typed: strong
require 'fear/either_api'
require 'fear/extractor_api'
require 'fear/for_api'
require 'fear/future_api'
require 'fear/option_api'
require 'fear/pattern_matching_api'
require 'fear/try_api'
require 'fear/version'

module Fear
  Error = Class.new(StandardError)
  IllegalStateException = Class.new(Error)
  MatchError = Class.new(Error)
  NoSuchElementError = Class.new(Error)
  PatternSyntaxError = Class.new(Error)

  extend EitherApi
  extend ExtractorApi
  extend ForApi
  extend FutureApi
  extend OptionApi
  extend PatternMatchingApi
  extend TryApi

  autoload :EmptyPartialFunction, 'fear/empty_partial_function'
  autoload :PartialFunction, 'fear/partial_function'
  autoload :PartialFunctionClass, 'fear/partial_function_class'
  autoload :PatternMatch, 'fear/pattern_match'
  autoload :Extractor, 'fear/extractor'

  autoload :Unit, 'fear/unit'
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

  autoload :Await, 'fear/await'
  autoload :Awaitable, 'fear/awaitable'
  autoload :Future, 'fear/future'
  autoload :Promise, 'fear/promise'

  autoload :Struct, 'fear/struct'

  module Mixin
    include Either::Mixin
    include For::Mixin
    include Option::Mixin
    include Try::Mixin
  end
end
