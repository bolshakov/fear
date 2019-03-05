module Fear
  module PartialFunction
    EMPTY = Object.new.extend(PartialFunction)
    EMPTY.instance_eval do
      def defined_at?(_)
        false
      end

      def call(arg)
        raise MatchError, "partial function not defined at: #{arg}"
      end

      def call_or_else(arg)
        yield arg
      end

      def or_else(other)
        other
      end

      def and_then(*)
        self
      end

      def to_s
        'Empty partial function'
      end
    end
    EMPTY.freeze
  end
end
