require 'bundler/gem_tasks'
require 'benchmark/ips'
require_relative 'lib/fear'
require 'any'

namespace :perf do
  namespace :and_then do
    task :call_or_else_proc do
      class NotOptimized < Fear::PartialFunction::AndThen
        def call_or_else(arg)
          if partial_function.defined_at?(arg)
            function.call(partial_function.call(arg))
          else
            yield arg
          end
        end
      end

      class OptimizedScalish < Fear::PartialFunction::AndThen
        FALLBACK = ->(*) { FALLBACK }
        class << self
          def fallback_occurred(x)
            x.__id__ == FALLBACK.__id__
          end
        end

        def call_or_else(arg)
          result = partial_function.call_or_else(arg, &FALLBACK)
          if OptimizedScalish.fallback_occurred(result)
            yield arg
          else
            function.call(result)
          end
        end
      end

      class OptimizedRubish < Fear::PartialFunction::AndThen
        TAG = Object.new.freeze

        def call_or_else(arg)
          catch(TAG) do
            result = partial_function.call_or_else(arg) { throw(TAG, yield(arg)) }
            function.call(result)
          end
        end
      end

      class OptimizedReturn < Fear::PartialFunction::AndThen
        def call_or_else(arg)
          result = partial_function.call_or_else(arg) do
            return yield(arg)
          end
          function.call(result)
        end
      end

      pf = Fear::PartialFunctionClass.new(->(x) { x.odd? }) { |x| x }
      default = ->(*) { 'default' }
      fallback = ->(*) { 'fallback' }

      not_optimized = NotOptimized.new(pf, &default)
      optimized_scalish = OptimizedScalish.new(pf, &default)
      optimized_rubish = OptimizedRubish.new(pf, &default)
      optimized_return = OptimizedReturn.new(pf, &default)

      Benchmark.ips do |x|
        x.report('AndThen#call_or_else optimized return') do |n|
          n.times do |t|
            optimized_return.call_or_else(t, &fallback)
          end
        end

        x.report('AndThen#call_or_else not optimized') do |n|
          n.times do |t|
            not_optimized.call_or_else(t, &fallback)
          end
        end

        x.compare!
      end

      Benchmark.ips do |x|
        x.report('AndThen#call_or_else optimized scalish') do |n|
          n.times do |t|
            optimized_scalish.call_or_else(t, &fallback)
          end
        end

        x.report('AndThen#call_or_else not optimized') do |n|
          n.times do |t|
            not_optimized.call_or_else(t, &fallback)
          end
        end

        x.compare!
      end

      Benchmark.ips do |x|
        x.report('AndThen#call_or_else optimized rubish') do |n|
          n.times do |t|
            optimized_rubish.call_or_else(t, &fallback)
          end
        end

        x.report('AndThen#call_or_else not optimized') do |n|
          n.times do |t|
            not_optimized.call_or_else(t, &fallback)
          end
        end

        x.compare!
      end
    end

    task :call_or_else_partial_function do
      class NotOptimized < Fear::PartialFunction::Combined
        def call_or_else(arg)
          if f1.defined_at?(arg)
            f2.call_or_else(f1.call(arg)) do |_|
              yield arg
            end
          else
            yield arg
          end
        end
      end

      class Optimized < Fear::PartialFunction::Combined
        def call_or_else(arg)
          result = f1.call_or_else(arg) { yield arg }

          f2.call_or_else(result) do |_|
            return yield(arg)
          end
        end
      end

      pf1 = Fear::PartialFunctionClass.new(->(x) { x.even? }) { |x| x }
      pf2 = Fear::PartialFunctionClass.new(->(x) { x % 3 == 0 }) { |x| x }
      fallback = ->(*) { 'fallback' }

      optimized = Optimized.new(pf1, pf2)
      not_optimized = NotOptimized.new(pf1, pf2)

      Benchmark.ips do |x|
        x.report('Combined#call_or_else optimized') do |n|
          n.times do |t|
            optimized.call_or_else(t, &fallback)
          end
        end

        x.report('Combined#call_or_else not optimized') do |n|
          n.times do |t|
            not_optimized.call_or_else(t, &fallback)
          end
        end

        x.compare!
      end
    end

    task :defined_at_partial_function do
      class NotOptimized < Fear::PartialFunction::Combined
        def defined_at?(arg)
          if f1.defined_at?(arg)
            f2.defined_at?(f1.call(arg))
          else
            false
          end
        end
      end

      class Optimized < Fear::PartialFunction::Combined
        def defined_at?(arg)
          result = f1.call_or_else(arg) do
            return false
          end
          f2.defined_at?(result)
        end
      end

      pf1 = Fear::PartialFunctionClass.new(->(x) { x.odd? }) { |x| x }
      pf2 = Fear::PartialFunctionClass.new(->(x) { x.even? }) { |x| x }

      optimized = Optimized.new(pf1, pf2)
      not_optimized = NotOptimized.new(pf1, pf2)

      Benchmark.ips do |x|
        x.report('Combined#defined_at? optimized') do |n|
          n.times do |t|
            optimized.defined_at?(t)
          end
        end

        x.report('Combined#defined_at? not optimized') do |n|
          n.times do |t|
            not_optimized.defined_at?(t)
          end
        end

        x.compare!
      end
    end
  end

  namespace :or_else do
    task :call_or_else do
      class NotOptimized < Fear::PartialFunction::OrElse
        def call_or_else(arg)
          if f1.defined_at?(arg)
            f1.call(arg)
          elsif f2.defined_at?(arg)
            f2.call(arg)
          else
            yield arg
          end
        end
      end

      class Optimized < Fear::PartialFunction::OrElse
        def call_or_else(arg, &fallback)
          f1.call_or_else(arg) do
            return f2.call_or_else(arg, &fallback)
          end
        end
      end

      pf1 = Fear::PartialFunctionClass.new(->(x) { x.odd? }) { |x| x }
      pf2 = Fear::PartialFunctionClass.new(->(x) { x.even? }) { |x| x }

      fallback = ->(*) { 'fallback' }

      optimized = Optimized.new(pf1, pf2)
      not_optimized = NotOptimized.new(pf1, pf2)

      Benchmark.ips do |x|
        x.report('OrElse#call_or_else optimized') do |n|
          n.times do |t|
            optimized.call_or_else(t, &fallback)
          end
        end

        x.report('OrElse#call_or_else not optimized') do |n|
          n.times do |t|
            not_optimized.call_or_else(t, &fallback)
          end
        end

        x.compare!
      end
    end

    task :or_else do
      class NotOptimized < Fear::PartialFunction::OrElse
        def or_else(other)
          NotOptimized.new(self, other)
        end
      end

      class Optimized < Fear::PartialFunction::OrElse
        def or_else(other)
          Optimized.new(f1, f2.or_else(other))
        end
      end

      pf1 = Fear::PartialFunctionClass.new(->(x) { x.even? }) { |x| x }
      pf2 = Fear::PartialFunctionClass.new(->(x) { x % 3 == 0 }) { |x| x }
      pf3 = Fear::PartialFunctionClass.new(->(x) { x % 5 == 0 }) { |x| x }

      fallback = ->(*) { 'fallback' }

      optimized = Optimized.new(pf1, pf2).or_else(pf3)
      not_optimized = NotOptimized.new(pf1, pf2).or_else(pf3)

      Benchmark.ips do |x|
        x.report('OrElse#or_else#call_or_else optimized') do |n|
          n.times do |t|
            optimized.call_or_else(t, &fallback)
          end
        end

        x.report('OrElse#or_else#call_or_else not optimized') do |n|
          n.times do |t|
            not_optimized.call_or_else(t, &fallback)
          end
        end

        x.compare!
      end
    end

    task :and_then do
      class NotOptimized < Fear::PartialFunction::OrElse
        def and_then(&block)
          AndThen.new(self, &block)
        end
      end

      class Optimized < Fear::PartialFunction::OrElse
        def and_then(&block)
          OrElse.new(@f1.and_then(&block), @f2.and_then(&block))
        end
      end

      pf1 = Fear::PartialFunctionClass.new(->(x) { x.even? }) { |x| x }
      pf2 = Fear::PartialFunctionClass.new(->(x) { x % 3 == 0 }) { |x| x }

      block = ->(*) { 'blk' }
      fallback = ->(*) { 'fallback' }

      optimized = Optimized.new(pf1, pf2).and_then(&block)
      not_optimized = NotOptimized.new(pf1, pf2).and_then(&block)

      Benchmark.ips do |x|
        x.report('OrElse#or_else#and_then optimized') do |n|
          n.times do |t|
            optimized.call_or_else(t, &fallback)
          end
        end

        x.report('OrElse#or_else#and_then not optimized') do |n|
          n.times do |t|
            not_optimized.call_or_else(t, &fallback)
          end
        end

        x.compare!
      end
    end
  end
end
