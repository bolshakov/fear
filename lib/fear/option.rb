module Fear
  # Represents optional values. Instances of +Option+
  # are either an instance of +Some+ or the object +None+.
  #
  # @example The most idiomatic way to use an +Option+ instance is to treat it as a collection
  #   name = Option(params[:name])
  #   upper = name.map(&:strip).select { |n| n.length != 0 }.map(&:upcase)
  #   puts upper.get_or_else('')
  #
  # This allows for sophisticated chaining of +Option+ values without
  # having to check for the existence of a value.
  #
  # @example A less-idiomatic way to use +Option+ values is via pattern matching
  #   Option(params[:name]).match do |m|
  #     m.some { |name| name.strip.upcase }
  #     m.none { 'No name value' }
  #   end
  #
  # @example or manually checking for non emptiness
  #   name = Option(params[:name])
  #   if name.empty?
  #     puts 'No name value'
  #   else
  #     puts name.strip.upcase
  #   end
  #
  # @!method get_or_else(*args)
  #   Returns the value from this +Some+ or evaluates the given
  #   default argument if this is a +None+.
  #   @overload get_or_else(&default)
  #     @yieldreturn [any]
  #     @return [any]
  #     @example
  #       Some(42).get_or_else { 24/2 } #=> 42
  #       None.get_or_else { 24/2 }   #=> 12
  #   @overload get_or_else(default)
  #     @return [any]
  #     @example
  #       Some(42).get_or_else(12)  #=> 42
  #       None.get_or_else(12)    #=> 12
  #
  # @!method or_else(&alternative)
  #   Returns this +Some+ or the given alternative if this is a +None+.
  #   @return [Option]
  #   @example
  #     Some(42).or_else { Some(21) } #=> Some(42)
  #     None.or_else { Some(21) }   #=> Some(21)
  #     None.or_else { None }     #=> None
  #
  # @!method include?(other_value)
  #   Returns +true+ if it has an element that is equal
  #   (as determined by +==+) to +other_value+, +false+ otherwise.
  #   @param [any]
  #   @return [Boolean]
  #   @example
  #     Some(17).include?(17) #=> true
  #     Some(17).include?(7)  #=> false
  #     None.include?(17)   #=> false
  #
  # @!method each(&block)
  #   Performs the given block if this is a +Some+.
  #   @yieldparam [any] value
  #   @yieldreturn [void]
  #   @return [Option] itself
  #   @example
  #     Some(17).each do |value|
  #       puts value
  #     end #=> prints 17
  #
  #     None.each do |value|
  #       puts value
  #     end #=> does nothing
  #
  # @!method map(&block)
  #   Maps the given block to the value from this +Some+ or
  #   returns this if this is a +None+
  #   @yieldparam [any] value
  #   @yieldreturn [any]
  #   @example
  #     Some(42).map { |v| v/2 } #=> Some(21)
  #     None.map { |v| v/2 }   #=> None
  #
  # @!method flat_map(&block)
  #   Returns the given block applied to the value from this +Some+
  #   or returns this if this is a +None+
  #   @yieldparam [any] value
  #   @yieldreturn [Option]
  #   @return [Option]
  #   @example
  #     Some(42).flat_map { |v| Some(v/2) }   #=> Some(21)
  #     None.flat_map { |v| Some(v/2) }     #=> None
  #
  # @!method to_a
  #   Returns an +Array+ containing the +Some+ value or an
  #   empty +Array+ if this is a +None+
  #   @return [Array]
  #   @example
  #     Some(42).to_a #=> [21]
  #     None.to_a   #=> []
  #
  # @!method any?(&predicate)
  #   Returns +false+ if +None+ or returns the result of the
  #   application of the given predicate to the +Some+ value.
  #   @yieldparam [any] value
  #   @yieldreturn [Boolean]
  #   @return [Boolean]
  #   @example
  #     Some(12).any?( |v| v > 10)  #=> true
  #     Some(7).any?( |v| v > 10)   #=> false
  #     None.any?( |v| v > 10)    #=> false
  #
  # @!method select(&predicate)
  #   Returns self if it is nonempty and applying the predicate to this
  #   +Option+'s value returns +true+. Otherwise, return +None+.
  #   @yieldparam [any] value
  #   @yieldreturn [Boolean]
  #   @return [Option]
  #   @example
  #     Some(42).select { |v| v > 40 } #=> Success(21)
  #     Some(42).select { |v| v < 40 } #=> None
  #     None.select { |v| v < 40 }   #=> None
  #
  # @!method reject(&predicate)
  #   Returns +Some+ if applying the predicate to this
  #   +Option+'s value returns +false+. Otherwise, return +None+.
  #   @yieldparam [any] value
  #   @yieldreturn [Boolean]
  #   @return [Option]
  #   @example
  #     Some(42).reject { |v| v > 40 } #=> None
  #     Some(42).reject { |v| v < 40 } #=> Some(42)
  #     None.reject { |v| v < 40 }   #=> None
  #
  # @!method get
  #   @return [any] the +Option+'s value.
  #   @raise [NoSuchElementError] if the option is empty.
  #
  # @!method empty?
  #   Returns +true+ if the +Option+ is +None+, +false+ otherwise.
  #   @return [Boolean]
  #   @example
  #     Some(42).empty? #=> false
  #     None.empty?   #=> true
  #
  # @!method match(&matcher)
  #   Pattern match against this +Option+
  #   @yield matcher [Fear::OptionPatternMatch]
  #   @example
  #     Option(val).match do |m|
  #       m.some(Integer) do |x|
  #        x * 2
  #       end
  #
  #       m.some(String) do |x|
  #         x.to_i * 2
  #       end
  #
  #       m.none { 'NaN' }
  #       m.else { 'error '}
  #     end
  #
  # @see https://github.com/scala/scala/blob/2.11.x/src/library/scala/Option.scala
  #
  module Option
    # @private
    def left_class
      NoneClass
    end

    # @private
    def right_class
      Some
    end

    class << self
      # Build pattern matcher to be used later, despite off
      # +Option#match+ method, id doesn't apply matcher immanently,
      # but build it instead. Unusually in sake of efficiency it's better
      # to statically build matcher and reuse it later.
      #
      # @example
      #   matcher =
      #     Option.matcher do |m|
      #       m.some(Integer) { |x| x * 2 }
      #       m.some(String) { |x| x.to_i * 2 }
      #       m.none { 'NaN' }
      #       m.else { 'error '}
      #     end
      #   matcher.call(Some(42))
      #
      # @yieldparam [OptionPatternMatch]
      # @return [Fear::PartialFunction]
      def matcher(&matcher)
        OptionPatternMatch.new(&matcher)
      end
    end

    # Include this mixin to access convenient factory methods.
    # @example
    #   include Fear::Option::Mixin
    #
    #   Option(17)  #=> #<Fear::Some value=17>
    #   Option(nil) #=> #<Fear::None>
    #   Some(17)    #=> #<Fear::Some value=17>
    #   None        #=> #<Fear::None>
    #
    module Mixin
      None = Fear::None

      # An +Option+ factory which creates +Some+ if the argument is
      # not +nil+, and +None+ if it is +nil+.
      # @param value [any]
      # @return [Some, None]
      #
      # @example
      #   Option(v)
      #
      def Option(value)
        if value.nil?
          None
        else
          Some(value)
        end
      end

      # @return [None]
      def None
        Fear::None
      end

      # @param value [any] except nil
      # @return [None]
      def Some(value)
        Some.new(value)
      end
    end
  end
end
