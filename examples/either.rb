# typed: strict
require 'fear'

either =
  if rand(0..1).zero?
    Fear.right(42)
  else
    Fear.left('Foo')
  end

either.get_or_else { true }
either.include?(42)

either.each { |v| puts v }
either.map(&:odd?)
either.flat_map { |v| Fear.right(v.odd?) }
either.to_option
either.any?(&:odd?)
either.right?
either.left?
either.select_or_else(-> { 'either odd' }, &:odd?)
either.select_or_else('either odd', &:odd?)
either.select_or_else('either odd', &:even?)
either.select_or_else(-> { 'either odd' }, &:even?)
either.select(&:odd?)
either.reject(&:odd?)
either.swap
either.reduce(->(_) { _.size }, ->(_) { _.odd? })

T.reveal_type either.join_right
# either.get
# either.empty?
# either.or_nil
#
# Fear::either.matcher do |m|
#   m.some(42, &:odd?)
#   m.none { 42 }
# end
#
# name = Fear.either(('Robert ' if rand(0..1).zero?))
# upper = name.map(&:strip).reject(&:empty?).map(&:upcase)
# puts(upper.get_or_else { 'not provided' })
