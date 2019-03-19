require 'bundler/gem_tasks'
require 'benchmark/ips'
require_relative 'lib/fear'

namespace :perf do
  task :pattern_matching_with_without_cache do
    some = Fear.some([:err, 'not found'])

    class WOCache < Fear::Extractor::Pattern
      def initialize(pattern)
        @matcher = compile_pattern_without_cache(pattern)
      end
    end

    Benchmark.ips do |x|
      x.report('With cache') do |_n|
        Fear::Extractor::Pattern.new('Fear::Some([:err, code])') === some
      end

      x.report('Without cache') do |_n|
        WOCache.new('Fear::Some([:err, code])') === some
      end

      x.compare!
    end
  end
  namespace :guard do
    task :and1 do
      condition = Integer

      Benchmark.ips do |x|
        x.report('Guard.new') do |n|
          Fear::PartialFunction::Guard.new(condition) === n
        end

        x.report('Guard.single') do |n|
          Fear::PartialFunction::Guard.and1(condition) === n
        end

        x.compare!
      end
    end

    task :and1 do
      first = Integer

      and1 = Fear::PartialFunction::Guard.and1(first)
      guard = Fear::PartialFunction::Guard.new(first)

      Benchmark.ips do |x|
        x.report('guard') do |n|
          and1 === n
        end

        x.report('single') do |n|
          guard === n
        end

        x.compare!
      end
    end

    task :and2 do
      first = Integer
      second = ->(x) { x > 2 }

      and2 = Fear::PartialFunction::Guard.and2(first, second)
      and_and = Fear::PartialFunction::Guard.new(first).and(Fear::PartialFunction::Guard.new(second))

      Benchmark.ips do |x|
        x.report('and2') do |n|
          and2 === n
        end

        x.report('Guard#and') do |n|
          and_and === n
        end

        x.compare!
      end
    end

    task :and3 do
      first = Integer
      second = ->(x) { x > 2 }
      third = ->(x) {  x < 10 }

      and3 = Fear::PartialFunction::Guard.and3(first, second, third)

      and_and_and = Fear::PartialFunction::Guard.new(first)
                                                .and(Fear::PartialFunction::Guard.new(second))
                                                .and(Fear::PartialFunction::Guard.new(third))

      Benchmark.ips do |x|
        x.report('Guard.and3') do |n|
          and3 === n
        end

        x.report('Guard#and') do |n|
          and_and_and === n
        end

        x.compare!
      end
    end
  end

  require 'qo'
  require 'dry/matcher'

  namespace :pattern_matching do
    task :try do
      module ExhaustivePatternMatch
        def initialize(*)
          super
          @default ||= self.else { raise Fear::MatchError }
        end
      end

      SuccessBranch = Qo.create_branch(name: 'success', precondition: Fear::Success, extractor: :get)
      FailureBranch = Qo.create_branch(name: 'failure', precondition: Fear::Failure, extractor: :exception)

      PatternMatch = Qo.create_pattern_match(
        branches: [
          SuccessBranch,
          FailureBranch,
        ],
      ).prepend(ExhaustivePatternMatch)

      Fear::Success.include(PatternMatch.mixin(as: :qo_match))

      success_case = Dry::Matcher::Case.new(
        match: lambda { |try, *pattern|
          try.is_a?(Fear::Success) && pattern.all? { |p| p === try.get }
        },
        resolve: ->(try) { try.get },
      )

      failure_case = Dry::Matcher::Case.new(
        match: lambda { |try, *pattern|
          try.is_a?(Fear::Failure) && pattern.all? { |p| p === try.exception }
        },
        resolve: ->(value) { value.exception },
      )

      # Build the matcher
      matcher = Dry::Matcher.new(success: success_case, failure: failure_case)

      success = Fear::Success.new(4)

      Benchmark.ips do |x|
        x.report('Qo') do
          success.qo_match do |m|
            m.failure { |y| y }
            m.success(->(y) { y % 4 == 0 }) { |y| y }
            m.success { 'else' }
          end
        end

        x.report('Fear') do
          success.match do |m|
            m.failure { |y| y }
            m.success(->(y) { y % 4 == 0 }) { |y| y }
            m.success { 'else' }
          end
        end

        x.report('Dr::Matcher') do
          matcher.call(success) do |m|
            m.failure { |_y| 'failure' }
            m.success(->(y) { y % 4 == 0 }) { |y| "2: #{y}" }
            m.success { 'else' }
          end
        end

        x.compare!
      end
    end

    task :either do
      module ExhaustivePatternMatch
        def initialize(*)
          super
          @default ||= self.else { raise Fear::MatchError }
        end
      end

      RightBranch = Qo.create_branch(name: 'right', precondition: Fear::Right, extractor: :right_value)
      LeftBranch = Qo.create_branch(name: 'left', precondition: Fear::Left, extractor: :left_value)

      PatternMatch = Qo.create_pattern_match(
        branches: [
          RightBranch,
          LeftBranch,
        ],
      ).prepend(ExhaustivePatternMatch)

      Fear::Right.include(PatternMatch.mixin(as: :qo_match))

      right = Fear::Right.new(4)

      Benchmark.ips do |x|
        x.report('Qo') do
          right.qo_match do |m|
            m.left(->(y) { y % 3 == 0 }) { |y| y }
            m.right(->(y) { y % 4 == 0 }) { |y| y }
            m.else { 'else' }
          end
        end

        x.report('Fear') do
          right.match do |m|
            m.left(->(y) { y % 3 == 0 }) { |y| y }
            m.right(->(y) { y % 4 == 0 }) { |y| y }
            m.else { 'else' }
          end
        end

        x.compare!
      end
    end

    task :option do
      module ExhaustivePatternMatch
        def initialize(*)
          super
          @default ||= self.else { raise Fear::MatchError }
        end
      end

      SomeBranch = Qo.create_branch(name: 'some', precondition: Fear::Some, extractor: :get)
      NoneBranch = Qo.create_branch(name: 'none', precondition: Fear::None)

      PatternMatch = Qo.create_pattern_match(
        branches: [
          SomeBranch,
          NoneBranch,
        ],
      ).prepend(ExhaustivePatternMatch)

      Fear::Some.include(PatternMatch.mixin(as: :qo_match))

      some = Fear::Some.new(4)

      some_case = Dry::Matcher::Case.new(
        match: lambda { |option, *pattern|
          option.is_a?(Fear::Some) && pattern.all? { |p| p === option.get }
        },
        resolve: ->(try) { try.get },
      )

      none_case = Dry::Matcher::Case.new(
        match: lambda { |option, *pattern|
          Fear::None == option && pattern.all? { |p| p === option }
        },
        resolve: ->(value) { value },
      )

      else_case = Dry::Matcher::Case.new(
        match: ->(*) { true },
        resolve: ->(value) { value },
      )

      # Build the matcher
      matcher = Dry::Matcher.new(some: some_case, none: none_case, else: else_case)

      option_matcher = Fear::Option.matcher do |m|
        m.some(->(y) { y % 3 == 0 }) { |y| y }
        m.some(->(y) { y % 4 == 0 }) { |y| y }
        m.none { 'none' }
        m.else { 'else' }
      end

      Benchmark.ips do |x|
        x.report('Qo') do
          some.qo_match do |m|
            m.some(->(y) { y % 3 == 0 }) { |y| y }
            m.some(->(y) { y % 4 == 0 }) { |y| y }
            m.none { 'none' }
            m.else { 'else' }
          end
        end

        x.report('Fear::Some#math') do
          some.match do |m|
            m.some(->(y) { y % 3 == 0 }) { |y| y }
            m.some(->(y) { y % 4 == 0 }) { |y| y }
            m.none { 'none' }
            m.else { 'else' }
          end
        end

        x.report('Fear::Option.mather') do
          option_matcher.call(some)
        end

        x.report('Dry::Matcher') do
          matcher.call(some) do |m|
            m.some(->(y) { y % 3 == 0 }) { |y| y }
            m.some(->(y) { y % 4 == 0 }) { |y| y }
            m.none { 'none' }
            m.else { 'else' }
          end
        end

        x.compare!
      end
    end

    task :option_execution do
      module ExhaustivePatternMatch
        def initialize(*)
          super
          @default ||= self.else { raise Fear::MatchError }
        end
      end

      SomeBranch = Qo.create_branch(name: 'some', precondition: Fear::Some, extractor: :get)
      NoneBranch = Qo.create_branch(name: 'none', precondition: Fear::None)

      PatternMatch = Qo.create_pattern_match(
        branches: [
          SomeBranch,
          NoneBranch,
        ],
      ).prepend(ExhaustivePatternMatch)

      some = Fear::Some.new(4)

      qo_matcher = PatternMatch.new do |m|
        m.some(->(y) { y % 3 == 0 }) { |y| y }
        m.some(->(y) { y % 4 == 0 }) { |y| y }
        m.none { 'none' }
        m.else { 'else' }
      end

      fear_matcher = Fear::OptionPatternMatch.new do |m|
        m.some(->(y) { y % 3 == 0 }) { |y| y }
        m.some(->(y) { y % 4 == 0 }) { |y| y }
        m.none { 'none' }
        m.else { 'else' }
      end

      Benchmark.ips do |x|
        x.report('Qo') do
          qo_matcher.call(some)
        end

        x.report('Fear') do
          fear_matcher.call(some)
        end

        x.compare!
      end
    end

    task :factorial do
      factorial_proc = proc do |n|
        if n <= 1
          1
        else
          n * factorial_proc.call(n - 1)
        end
      end

      factorial_pm = Fear.matcher do |m|
        m.case(->(n) { n <= 1 }) { 1 }
        m.else { |n| n * factorial_pm.call(n - 1) }
      end

      factorial_qo = Qo.match do |m|
        m.when(->(n) { n <= 1 }) { 1 }
        m.else { |n| n * factorial_qo.call(n - 1) }
      end

      Benchmark.ips do |x|
        x.report('Proc') do
          factorial_proc.call(100)
        end

        x.report('Fear') do
          factorial_pm.call(100)
        end

        x.report('Qo') do
          factorial_qo.call(100)
        end

        x.compare!
      end
    end

    task :construction_vs_execution do
      matcher = Fear::PatternMatch.new do |m|
        m.case(Integer) { |x| x * 2 }
        m.case(String) { |x| x.to_i(10) * 2 }
      end

      Benchmark.ips do |x|
        x.report('construction') do
          Fear::PatternMatch.new do |m|
            m.case(Integer) { |y| y * 2 }
            m.case(String) { |y| y.to_i(10) * 2 }
          end
        end

        x.report('execution') do
          matcher.call(42)
        end

        x.compare!
      end
    end
  end
end
