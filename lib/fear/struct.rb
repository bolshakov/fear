# frozen_string_literal: true

module Fear
  # Structs are like regular classes and good for modeling immutable data.
  #
  # A minimal struct requires just a list of attributes:
  #
  #     User = Fear::Struct.with_attributes(:id, :email, :admin)
  #     john = User.new(id: 2, email: 'john@example.com', admin: false)
  #
  #     john.email #=> 'john@example.com'
  #
  # Instead of `.with_attributes` factory method you can use classic inheritance:
  #
  #     class User < Fear::Struct
  #       attribute :id
  #       attribute :email
  #       attribute :admin
  #     end
  #
  # Since structs are immutable, you are not allowed to reassign their attributes
  #
  #     john.email = "john.doe@example.com" #=> raises NoMethodError
  #
  # Two structs of the same type with the same attributes are equal
  #
  #     john1 = User.new(id: 2, email: 'john@example.com', admin: false)
  #     john2 = User.new(id: 2, admin: false, email: 'john@example.com')
  #     john1 == john2 #=> true
  #
  # You can create a shallow copy of a +Struct+ by using copy method optionally changing its attributes.
  #
  #     john = User.new(id: 2, email: 'john@example.com', admin: false)
  #     admin_john = john.copy(admin: true)
  #
  #     john.admin #=> false
  #     admin_john.admin #=> true
  #
  class Struct
    include PatternMatch.mixin

    @attributes = [].freeze

    class << self
      # @param base [Fear::Struct]
      # @api private
      def inherited(base)
        base.instance_variable_set(:@attributes, attributes)
      end

      # Defines attribute
      #
      # @param name [Symbol]
      # @return [Symbol] attribute name
      #
      # @example
      #   class User < Fear::Struct
      #     attribute :id
      #     attribute :email
      #   end
      #
      def attribute(name)
        name.to_sym.tap do |symbolized_name|
          @attributes << symbolized_name
          attr_reader symbolized_name
        end
      end

      # Members of this struct
      #
      # @return [<Symbol>]
      def attributes
        @attributes.dup
      end

      # Creates new struct with given attributes
      # @param members [<Symbol>]
      # @return [Fear::Struct]
      #
      # @example
      #   User = Fear::Struct.with_attributes(:id, :email, :admin) do
      #     def admin?
      #       @admin
      #     end
      #   end
      #
      def with_attributes(*members, &block)
        members = members
        block = block

        Class.new(self) do
          members.each { |member| attribute(member) }
          class_eval(&block) if block
        end
      end
    end

    # @param attributes [{Symbol => any}]
    def initialize(**attributes)
      _check_missing_attributes!(attributes)
      _check_unknown_attributes!(attributes)

      @values = members.each_with_object([]) do |name, values|
        attributes.fetch(name).tap do |value|
          _set_attribute(name, value)
          values << value
        end
      end
    end

    # Creates a shallow copy of this struct optionally changing the attributes arguments.
    # @param attributes [{Symbol => any}]
    #
    # @example
    #   User = Fear::Struct.new(:id, :email, :admin)
    #   john = User.new(id: 2, email: 'john@example.com', admin: false)
    #   john.admin #=> false
    #   admin_john = john.copy(admin: true)
    #   admin_john.admin #=> true
    #
    def copy(**attributes)
      self.class.new(**to_h.merge(attributes))
    end

    # Returns the struct attributes as an array of symbols
    # @return [<Symbol>]
    #
    # @example
    #   User = Fear::Struct.new(:id, :email, :admin)
    #   john = User.new(email: 'john@example.com', admin: false, id: 2)
    #   john.attributes #=> [:id, :email, :admin]
    #
    def members
      self.class.attributes
    end

    # Returns the values for this struct as an Array.
    # @return [Array]
    #
    # @example
    #   User = Fear::Struct.new(:id, :email, :admin)
    #   john = User.new(email: 'john@example.com', admin: false, id: 2)
    #   john.to_a #=> [2, 'john@example.com', false]
    #
    def to_a
      @values.dup
    end

    # @overload to_h()
    #   Returns a Hash containing the names and values for the struct's attributes
    #   @return [{Symbol => any}]
    #
    # @overload to_h(&block)
    #   Applies block to pairs of name name and value and use them to construct hash
    #   @yieldparam pair [<Symbol, any>] yields pair of name name and value
    #   @return [{Symbol => any}]
    #
    # @example
    #   User = Fear::Struct.new(:id, :email, :admin)
    #   john = User.new(email: 'john@example.com', admin: false, id: 2)
    #   john.to_h #=> {id: 2, email: 'john@example.com', admin: false}
    #   john.to_h do |key, value|
    #     [key.to_s, value]
    #   end #=> {'id' => 2, 'email' => 'john@example.com', 'admin' => false}
    #
    def to_h(&block)
      pairs = members.zip(@values)
      if block_given?
        Hash[pairs.map(&block)]
      else
        Hash[pairs]
      end
    end

    # @param other [any]
    # @return [Boolean]
    def ==(other)
      other.is_a?(other.class) && to_h == other.to_h
    end

    INSPECT_TEMPLATE = "<#Fear::Struct %{class_name} %{attributes}>"
    private_constant :INSPECT_TEMPLATE

    # @return [String]
    #
    # @example
    #   User = Fear::Struct.with_attributes(:id, :email)
    #   user = User.new(id: 2, email: 'john@exmaple.com')
    #   user.inspect #=> "<#Fear::Struct User id=2, email=>'john@exmaple.com'>"
    #
    def inspect
      attributes = to_h.map { |key, value| "#{key}=#{value.inspect}" }.join(", ")

      format(INSPECT_TEMPLATE, class_name: self.class.name, attributes: attributes)
    end
    alias to_s inspect

    MISSING_KEYWORDS_ERROR = "missing keywords: %{keywords}"
    private_constant :MISSING_KEYWORDS_ERROR

    private def _check_missing_attributes!(provided_attributes)
      missing_attributes = members - provided_attributes.keys

      unless missing_attributes.empty?
        raise ArgumentError, format(MISSING_KEYWORDS_ERROR, keywords: missing_attributes.join(", "))
      end
    end

    UNKNOWN_KEYWORDS_ERROR = "unknown keywords: %{keywords}"
    private_constant :UNKNOWN_KEYWORDS_ERROR

    private def _check_unknown_attributes!(provided_attributes)
      unknown_attributes = provided_attributes.keys - members

      unless unknown_attributes.empty?
        raise ArgumentError, format(UNKNOWN_KEYWORDS_ERROR, keywords: unknown_attributes.join(", "))
      end
    end

    # @return [void]
    private def _set_attribute(name, value)
      instance_variable_set(:"@#{name}", value)
    end

    # @param keys [Hash, nil]
    # @return [Hash]
    def deconstruct_keys(keys)
      if keys
        to_h.slice(*(self.class.attributes & keys))
      else
        to_h
      end
    end
  end
end
