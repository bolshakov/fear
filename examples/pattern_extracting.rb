# typed: true
require 'fear'

User = Struct.new(:id, :name, :admin)

matcher = Fear.matcher do |m|
  m.xcase('User(_, name, true)') do |name:|
    puts "Hi #{name}, you are welcome"
  end
  m.xcase('User(_, _, false)') do
    puts 'Only admins allowed here'
  end
end

matcher.call User.new(1, 'Jane', true)
matcher.call User.new(1, 'John', false)
