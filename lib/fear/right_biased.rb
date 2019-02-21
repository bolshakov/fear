module Fear
  # @private
  module RightBiased
    # Performs necessary interface and type checks.
    #
    module Interface
      # Returns the value from this `RightBiased::Right` or the given argument if
      # this is a `RightBiased::Left`.
      def get_or_else(*args, &block)
        Utils.assert_arg_or_block!('get_or_else', *args, &block)
        super
      end

      # Returns this `RightBiased::Right` or the given alternative if
      # this is a `RightBiased::Left`.
      def or_else(*args, &block)
        Utils.assert_arg_or_block!('or_else', *args, &block)
        super.tap do |result|
          Utils.assert_type!(result, left_class, right_class)
        end
      end

      def flat_map
        super.tap do |result|
          Utils.assert_type!(result, left_class, right_class)
        end
      end

      # Ensures that returned value either left, or right.
      def select(*)
        super.tap do |result|
          Utils.assert_type!(result, left_class, right_class)
        end
      end
    end

    module Right
      class << self
        def included(base)
          base.prepend Interface
        end
      end

      # @overload get_or_else(default)
      #   @param default [any]
      #   @return [any] the `#value`.
      #
      # @overload get_or_else(&default)
      #   @return [any] the `#value`.
      #
      def get_or_else(*_args)
        value
      end

      # @return [self]
      def or_else
        self
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

      # @return [Array] containing value
      def to_a
        [value]
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
      prepend Interface
      include Utils
      # @!method get_or_else(default)
      #   @param default [any]
      #   @return [any] default value
      #
      # @!method get_or_else(&default)
      #   @return [any] result of evaluating a block.
      #
      def get_or_else(*args)
        args.fetch(0) { yield }
      end

      # @!method get_or_else(&alternative)
      #   @return [RightBiased] result of evaluating a block.
      #
      def or_else(*_args)
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

      # @return [Array] empty array
      def to_a
        []
      end

      # @return [None]
      def to_option
        None.new
      end

      # @return [false]
      def any?
        false
      end
    end
  end
end
