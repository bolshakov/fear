# frozen_string_literal: true

require "fear"

User = Struct.new(:id, :name, :admin)

matcher = proc do |value|
  case value
  in User(admin: true, name:)
    puts "Hi #{name}, you are welcome"
  in User(admin: false)
    puts "Only admins are allowed here"
  end
end

matcher.call(User.new(1, "Jane", true))
matcher.call(User.new(1, "John", false))
