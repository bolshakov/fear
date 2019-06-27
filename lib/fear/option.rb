module Fear
  # Represents optional values. Instances of +Option+
  # are either an instance of +Some+ or the object +None+.
  #
  # @example The most idiomatic way to use an +Option+ instance is to treat it as a collection
  #   name = Fear.option(params[:name])
  #   upper = name.map(&:strip).select { |n| n.length != 0 }.map(&:upcase)
  #   puts upper.get_or_else { '' }
  #
  # This allows for sophisticated chaining of +Option+ values without
  # having to check for the existence of a value.
  #
  # @example A less-idiomatic way to use +Option+ values is via pattern matching
  #   Fear.option(params[:name]).match do |m|
  #     m.some { |name| name.strip.upcase }
  #     m.none { 'No name value' }
  #   end
  #
  # @example or manually checking for non emptiness
  #   name = Fear.option(params[:name])
  #   if name.empty?
  #     puts 'No name value'
  #   else
  #     puts name.strip.upcase
  #   end
  #
  # @!method get_or_else(&default)
  #   Returns the value from this +Some+ or evaluates the given
  #   default argument if this is a +None+.
  #  @yieldreturn [any]
  #  @return [any]
  #  @example
  #   Fear.some(42).get_or_else { 12 }  #=> 42
  #   Fear.none.get_or_else { }12 }    #=> 12
  #
  # @!method or_else(&alternative)
  #   Returns this +Some+ or the given alternative if this is a +None+.
  #   @return [Option]
  #   @example
  #     Fear.some(42).or_else { Fear.some(21) } #=> Fear.some(42)
  #     Fear.none.or_else { Fear.some(21) }   #=> Fear.some(21)
  #     Fear.none.or_else { None }     #=> None
  #
  # @!method include?(other_value)
  #   Returns +true+ if it has an element that is equal
  #   (as determined by +==+) to +other_value+, +false+ otherwise.
  #   @param [any]
  #   @return [Boolean]
  #   @example
  #     Fear.some(17).include?(17) #=> true
  #     Fear.some(17).include?(7)  #=> false
  #     Fear.none.include?(17)   #=> false
  #
  # @!method each(&block)
  #   Performs the given block if this is a +Some+.
  #   @yieldparam [any] value
  #   @yieldreturn [void]
  #   @return [Option] itself
  #   @example
  #     Fear.some(17).each do |value|
  #       puts value
  #     end #=> prints 17
  #
  #     Fear.none.each do |value|
  #       puts value
  #     end #=> does nothing
  #
  # @!method map(&block)
  #   Maps the given block to the value from this +Some+ or
  #   returns this if this is a +None+
  #   @yieldparam [any] value
  #   @yieldreturn [any]
  #   @example
  #     Fear.some(42).map { |v| v/2 } #=> Fear.some(21)
  #     Fear.none.map { |v| v/2 }   #=> None
  #
  # @!method flat_map(&block)
  #   Returns the given block applied to the value from this +Some+
  #   or returns this if this is a +None+
  #   @yieldparam [any] value
  #   @yieldreturn [Option]
  #   @return [Option]
  #   @example
  #     Fear.some(42).flat_map { |v| Fear.some(v/2) }   #=> Fear.some(21)
  #     Fear.none.flat_map { |v| Fear.some(v/2) }     #=> None
  #
  # @!method any?(&predicate)
  #   Returns +false+ if +None+ or returns the result of the
  #   application of the given predicate to the +Some+ value.
  #   @yieldparam [any] value
  #   @yieldreturn [Boolean]
  #   @return [Boolean]
  #   @example
  #     Fear.some(12).any?( |v| v > 10)  #=> true
  #     Fear.some(7).any?( |v| v > 10)   #=> false
  #     Fear.none.any?( |v| v > 10)    #=> false
  #
  # @!method select(&predicate)
  #   Returns self if it is nonempty and applying the predicate to this
  #   +Option+'s value returns +true+. Otherwise, return +None+.
  #   @yieldparam [any] value
  #   @yieldreturn [Boolean]
  #   @return [Option]
  #   @example
  #     Fear.some(42).select { |v| v > 40 } #=> Fear.success(21)
  #     Fear.some(42).select { |v| v < 40 } #=> None
  #     Fear.none.select { |v| v < 40 }   #=> None
  #
  # @!method reject(&predicate)
  #   Returns +Some+ if applying the predicate to this
  #   +Option+'s value returns +false+. Otherwise, return +None+.
  #   @yieldparam [any] value
  #   @yieldreturn [Boolean]
  #   @return [Option]
  #   @example
  #     Fear.some(42).reject { |v| v > 40 } #=> None
  #     Fear.some(42).reject { |v| v < 40 } #=> Fear.some(42)
  #     Fear.none.reject { |v| v < 40 }   #=> None
  #
  # @!method get
  #   @return [any] the +Option+'s value.
  #   @raise [NoSuchElementError] if the option is empty.
  #
  # @!method empty?
  #   Returns +true+ if the +Option+ is +None+, +false+ otherwise.
  #   @return [Boolean]
  #   @example
  #     Fear.some(42).empty? #=> false
  #     Fear.none.empty?   #=> true
  #
  # @!method match(&matcher)
  #   Pattern match against this +Option+
  #   @yield matcher [Fear::OptionPatternMatch]
  #   @example
  #     Fear.option(val).match do |m|
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
      # +Option#match+ method, it doesn't apply matcher immanently,
      # but build it instead. Usually in sake of efficiency it's better
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
      #   matcher.call(Fear.some(42))
      #
      # @yieldparam [OptionPatternMatch]
      # @return [Fear::PartialFunction]
      def matcher(&matcher)
        OptionPatternMatch.new(&matcher)
      end

      def match(value, &block)
        matcher(&block).call(value)
      end
    end

    # Include this mixin to access convenient factory methods.
    # @example
    #   include Fear::Option::Mixin
    #
    #   Option(17) #=> #<Fear::Some get=17>
    #   Option(nil) #=> #<Fear::None>
    #   Some(17) #=> #<Fear::Some get=17>
    #   None() #=> #<Fear::None>
    #
    module Mixin
      # An +Option+ factory which creates +Some+ if the argument is
      # not +nil+, and +None+ if it is +nil+.
      # @param value [any]
      # @return [Fear::Some, Fear::None]
      #
      # @example
      #   Option(17) #=> #<Fear::Some get=17>
      #   Option(nil) #=> #<Fear::None>
      #
      def Option(value)
        Fear.option(value)
      end

      # @return [None]
      # @example
      #   None() #=> #<Fear::None>
      #
      def None
        Fear.none
      end

      # @param value [any] except nil
      # @return [Fear::Some]
      # @example
      #   Some(17) #=> #<Fear::Some get=17>
      #   Some(nil) #=> #<Fear::Some get=nil>
      #
      def Some(value)
        Fear.some(value)
      end
    end
  end
end
