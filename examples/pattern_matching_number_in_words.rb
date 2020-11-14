# frozen_string_literal: true

require "fear"

class ToWords
  NUMBERS = {
    0 => "zero",
    1 => "one",
    2 => "two",
    3 => "three",
    4 => "four",
    5 => "five",
    6 => "six",
    7 => "seven",
    8 => "eight",
    9 => "nine",
    10 => "ten",
    11 => "eleven",
    12 => "twelve",
    13 => "thirteen",
    14 => "fourteen",
    15 => "fifteen",
    16 => "sixteen",
    17 => "seventeen",
    18 => "eighteen",
    19 => "nineteen",
    20 => "twenty",
    30 => "thirty",
    40 => "forty",
    50 => "fifty",
    60 => "sixty",
    70 => "seventy",
    80 => "eighty",
    90 => "ninety",
  }.freeze
  private_constant :NUMBERS

  CONVERTER = Fear.matcher do |m|
    NUMBERS.each_pair do |number, in_words|
      m.case(number) { in_words }
    end
    m.case(->(n) { n < 0 }) { |n| "minus #{CONVERTER.(-n)}" }
    m.case(->(n) { n < 100 }) { |n| "#{CONVERTER.((n / 10) * 10)}-#{CONVERTER.(n % 10)}" }
    m.case(->(n) { n < 200 }) { |n| "one hundred #{CONVERTER.(n % 100)}" }
    m.case(->(n) { n < 1_000 }) { |n| "#{CONVERTER.(n / 100)} hundreds #{CONVERTER.(n % 100)}" }
    m.case(->(n) { n < 2_000 }) { |n| "one thousand #{CONVERTER.(n % 1000)}" }
    m.case(->(n) { n < 1_000_000 }) { |n| "#{CONVERTER.(n / 1_000)} thousands #{CONVERTER.(n % 1_000)}" }
    m.else { |n| raise "#{n} too big " }
  end
  private_constant :CONVERTER

  def self.call(number)
    Fear.case(Integer, &:itself).and_then(CONVERTER).(number)
  end
end

ToWords.(99) #=> 'ninety-nine'
ToWords.(133) #=> 'one hundred thirty-three
ToWords.(777) #=> 'seven hundreds seventy-seven'
ToWords.(254_555) #=> 'two hundreds fifty-four thousands five hundreds fifty-five'
