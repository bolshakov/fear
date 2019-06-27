module Fear
  # @private
  module RightBiased
    module Right
      include RightBiased

      # @overload get_or_else(&default)
      #   @return [any] the `#value`.
      #
      def get_or_else
        value
      end

      # @param [any]
      # @return [Boolean]
      def include?(other_value)
        value == other_value
      end

      # @return [self]
      def each
        yield(value)
        self
      end

      # Maps the value using given block.
      #
      # @return [RightBiased::Right]
      #
      def map
        self.class.new(yield(value))
      end

      # Binds the given function across `RightBiased::Right`.
      #
      # @return [RightBiased::Left, RightBiased::Right]
      #
      def flat_map
        yield(value)
      end

      # @return [Option] containing value
      def to_option
        Some.new(value)
      end

      # @return [Boolean] true if value satisfies predicate.
      def any?
        yield(value)
      end

      # Used in case statement
      # @param other [any]
      # @return [Boolean]
      def ===(other)
        if other.is_a?(right_class)
          value === other.value
        else
          super
        end
      end
    end

    module Left
      include RightBiased

      # @!method get_or_else(&default)
      #   @return [any] result of evaluating a block.
      #
      def get_or_else
        yield
      end

      # @param [any]
      # @return [false]
      #
      def include?(_value)
        false
      end

      # Ignores the given side-effecting block and return self.
      #
      # @return [RightBiased::Left]
      #
      def each
        self
      end

      # Ignores the given block and return self.
      #
      # @return [RightBiased::Left]
      #
      def map
        self
      end

      # Ignores the given block and return self.
      #
      # @return [RightBiased::Left]
      #
      def flat_map
        self
      end

      # @return [None]
      def to_option
        None
      end

      # @return [false]
      def any?
        false
      end
    end
  end
end
