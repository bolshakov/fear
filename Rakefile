# frozen_string_literal: true

require "bundler/gem_tasks"
require "benchmark/ips"
require "dry/monads"
require_relative "lib/fear"

include Dry::Monads[:maybe]

namespace :perf do
  # Contains benchmarking against Dry-rb
  namespace :dry do
    task :some_fmap_vs_fear_some_map do
      dry = Some(42)
      fear = Fear.some(42)

      Benchmark.ips do |x|
        x.report("Dry") { dry.fmap(&:itself) }

        x.report("Fear") { fear.map(&:itself) }

        x.compare!
      end
    end

    task :do_vs_fear_for do
      require "dry/monads/do"

      class Operation
        include Dry::Monads::Do.for(:call)

        def call
          m1 = Some(1)
          m2 = Some(2)

          one = yield m1
          two = yield m2

          Some(one + two)
        end
      end

      op = Operation.new

      Benchmark.ips do |x|
        x.report("Dry") { op.() }

        x.report("Fear") do |_n|
          Fear.for(Fear.some(1), Fear.some(2)) do |one, two|
            one + two
          end
        end

        x.compare!
      end
    end
  end

  # Contains internal benchmarking to if optimization works
  namespace :fear do
    namespace :guard do
      task :and1_vs_new do
        iterations = 1_000

        Benchmark.ips do |x|
          x.report("Guard.new") do |n|
            iterations.times do
              Fear::PartialFunction::Guard.new(Integer) === n
            end
          end

          x.report("Guard.and1") do |n|
            iterations.times do
              Fear::PartialFunction::Guard.and1(Integer) === n
            end
          end

          x.compare!
        end
      end

      task :and2_vs_and do
        iterations = 1_000
        first = Integer
        second = ->(x) { x > 2 }

        and2 = Fear::PartialFunction::Guard.and2(first, second)
        and_and = Fear::PartialFunction::Guard.new(first).and(Fear::PartialFunction::Guard.new(second))

        Benchmark.ips do |x|
          x.report("and2") do |n|
            iterations.times { and2 === n }
          end

          x.report("Guard#and") do |n|
            iterations.times { and_and === n }
          end

          x.compare!
        end
      end

      task :and3_vs_and_and do
        iterations = 1_000
        first = Integer
        second = ->(x) { x > 2 }
        third = ->(x) { x < 10 }

        and3 = Fear::PartialFunction::Guard.and3(first, second, third)

        and_and_and = Fear::PartialFunction::Guard.new(first)
          .and(Fear::PartialFunction::Guard.new(second))
          .and(Fear::PartialFunction::Guard.new(third))

        Benchmark.ips do |x|
          x.report("Guard.and3") do |n|
            iterations.times { and3 === n }
          end

          x.report("Guard#and") do |n|
            iterations.times { and_and_and === n }
          end

          x.compare!
        end
      end
    end

    task :pattern_matching_construction_vs_execution do
      matcher = Fear::PatternMatch.new do |m|
        m.case(Integer) { |x| x * 2 }
        m.case(String) { |x| x.to_i(10) * 2 }
      end

      Benchmark.ips do |x|
        x.report("construction") do
          Fear::PatternMatch.new do |m|
            m.case(Integer) { |y| y * 2 }
            m.case(String) { |y| y.to_i(10) * 2 }
          end
        end

        x.report("execution") do
          matcher.(42)
        end

        x.compare!
      end
    end

    task :option_match_vs_native_pattern_match do
      some = Fear.some(42)

      Benchmark.ips do |x|
        matcher = Fear::Option.matcher do |m|
          m.some(41, &:itself)
          m.some(42, &:itself)
          m.some(45, &:itself)
        end

        x.report("case ... in ...") do
          case some
          in Fear::Some(41 => x)
            x
          in Fear::Some(42 => x)
            x
          in Fear::Some(43 => x)
            x
          end
        end

        x.report("Option#match") do
          some.match do |m|
            m.some(41, &:itself)
            m.some(42, &:itself)
            m.some(45, &:itself)
          end
        end

        x.report("Option#matcher") do
          matcher.(some)
        end

        x.compare!
      end
    end
  end

  namespace :pattern_matching do
    require "dry/matcher"

    task :dry_vs_fear_try do
      success_case = Dry::Matcher::Case.new(
        match: ->(try, *pattern) {
          try.is_a?(Fear::Success) && pattern.all? { |p| p === try.get }
        },
        resolve: ->(try) { try.get },
      )

      failure_case = Dry::Matcher::Case.new(
        match: ->(try, *pattern) {
          try.is_a?(Fear::Failure) && pattern.all? { |p| p === try.exception }
        },
        resolve: ->(value) { value.exception },
      )

      # Build the matcher
      matcher = Dry::Matcher.new(success: success_case, failure: failure_case)

      success = Fear::Success.new(4)

      Benchmark.ips do |x|
        x.report("Fear") do
          success.match do |m|
            m.failure(&:itself)
            m.success(Integer, ->(y) { y % 5 == 0 }, &:itself)
            m.success { "else" }
          end
        end

        x.report("Dr::Matcher") do
          matcher.(success) do |m|
            m.failure(&:itself)
            m.success(Integer, ->(y) { y % 5 == 0 }, &:itself)
            m.success { "else" }
          end
        end

        x.compare!
      end
    end

    task :factorial do
      factorial_proc = proc do |n|
        if n <= 1
          1
        else
          n * factorial_proc.(n - 1)
        end
      end

      factorial_pm = Fear.matcher do |m|
        m.case(1, &:itself)
        m.case(0, &:itself)
        m.else { |n| n * factorial_pm.(n - 1) }
      end

      Benchmark.ips do |x|
        x.report("Proc") do
          factorial_proc.(100)
        end

        x.report("Fear") do
          factorial_pm.(100)
        end

        x.compare!
      end
    end
  end
end
