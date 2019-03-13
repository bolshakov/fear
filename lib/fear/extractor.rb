require 'dry/struct'
require 'treetop'
require 'fear/extractor/grammar'
Treetop.load File.expand_path('extractor/grammar.treetop', __dir__)

module Fear
  module Extractor
    module Types
      include Dry::Types.module
    end

    autoload :Pattern, 'fear/extractor/pattern'
    autoload :Matcher, 'fear/extractor/matcher'
    autoload :ArrayMatcher, 'fear/extractor/array_matcher'
    autoload :IntegerMatcher, 'fear/extractor/integer_matcher'
  end
end
