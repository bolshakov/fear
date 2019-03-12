require 'fear'

# @example Usage
#   set = BinaryTreeSet.new
#   set.add(4)
#   set.includes?(4) #=> true
#   set.includes?(5) #=> false
#   set.delete(4)
#   set.includes?(4) #=> false
#
class BinaryTreeSet
  Position = Module.new
  Right = Module.new.include(Position)
  Left = Module.new.include(Position)

  def initialize(elem = 0, removed: true)
    @elem = elem
    @removed = removed
    @subtrees = {}
  end
  attr_reader :elem, :subtrees
  attr_accessor :removed
  private :elem
  private :removed
  private :subtrees

  # @param value [Integer]
  # @return [Boolean]
  def includes?(value)
    Fear.match(value) do |m|
      m.case(elem) { !removed }
      m.case(->(x) { x > elem }) { |v| includes_in_leaf?(Right, v) }
      m.case(->(x) { x < elem }) { |v| includes_in_leaf?(Left, v) }
    end
  end

  # @param position [Position]
  # @param value [Integer]
  # @return [Boolean]
  private def includes_in_leaf?(position, value)
    leaf(position).match do |m|
      m.some { |leaf| leaf.includes?(value) }
      m.none { false }
    end
  end

  # @param value [Integer]
  # @return [void]
  def add(value)
    Fear.match(value) do |m|
      m.case(elem) { self.removed = false }
      m.case(->(x) { x > elem }) { |v| add_to_leaf(Right, v) }
      m.case(->(x) { x < elem }) { |v| add_to_leaf(Left, v) }
    end
  end

  # @param position [Position]
  # @param value [Integer]
  # @return [void]
  private def add_to_leaf(position, value)
    leaf(position).match do |m|
      m.some { |leaf| leaf.add(value) }
      m.none { subtrees[position] = BinaryTreeSet.new(value, removed: false) }
    end
  end

  # @param value [Integer]
  # @return [void]
  def delete(value)
    Fear.match(value) do |m|
      m.case(elem) { self.removed = true }
      m.case(->(x) { x > elem }) { |v| delete_from_leaf(Right, v) }
      m.case(->(x) { x < elem }) { |v| delete_from_leaf(Left, v) }
    end
  end

  # @param position [Position]
  # @param value [Integer]
  # @return [void]
  private def delete_from_leaf(position, value)
    leaf(position).match do |m|
      m.some { |leaf| leaf.delete(value) }
      m.none { subtrees[position] = BinaryTreeSet.new(value, removed: true) }
    end
  end

  # @param position [Position]
  # @return [Fear::Option<BinaryTreeSet>]
  private def leaf(position)
    if subtrees.key?(position)
      Fear.some(subtrees[position])
    else
      Fear.none
    end
  end
end
