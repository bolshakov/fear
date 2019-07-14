# frozen_string_literal: true

require "ostruct"

module Fear
  module Extractor
    class Matcher < OpenStruct
      # Combine two matchers, so both should pass
      class And < Matcher
        def initialize(matcher1, matcher2)
          @matcher1 = matcher1
          @matcher2 = matcher2
        end
        attr_reader :matcher1, :matcher2

        def defined_at?(arg)
          matcher1.defined_at?(arg) && matcher2.defined_at?(arg)
        end

        def bindings(arg)
          matcher1.bindings(arg).merge(matcher2.bindings(arg))
        end

        def failure_reason(arg)
          if matcher1.defined_at?(arg)
            if matcher2.defined_at?(arg)
              Fear.none
            else
              matcher2.failure_reason(arg)
            end
          else
            matcher1.failure_reason(arg)
          end
        end
      end
    end
  end
end
