# typed: strict
require 'fear'
# The most idiomatic way to use an +Option+ instance is to treat it as a collection

option = Fear.option((42 if rand(0..1).zero?))

option.get_or_else { 'faa' }
option.or_else { Fear.some('foo') }
option.include?(42)
option.each { |v| puts v }
option.map(&:odd?)
option.flat_map { |v| Fear.some(v.odd?) }
option.any?(&:odd?)
option.select(&:odd?)
option.reject(&:odd?)
option.get
option.empty?
option.to_option
option.or_nil

Fear::Option.matcher do |m|
  m.some(42, &:odd?)
  m.none { 42 }
end

name = Fear.option(('Robert ' if rand(0..1).zero?))
upper = name.map(&:strip).reject(&:empty?).map(&:upcase)
puts(upper.get_or_else { 'not provided' })
