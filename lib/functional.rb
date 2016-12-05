require 'dry-equalizer'
require 'functional/version'

module Functional
  Error = Class.new(StandardError)
  IllegalStateException = Class.new(Error)
  NoSuchElementError = Class.new(Error)

  autoload :Utils, 'functional/utils'

  autoload :Option, 'functional/option'
  autoload :Some, 'functional/some'
  autoload :None, 'functional/none'

  autoload :Try, 'functional/try'
  autoload :Success, 'functional/success'
  autoload :Failure, 'functional/failure'

  autoload :Future, 'functional/future'
  autoload :Promise, 'functional/promise'

  autoload :Either, 'functional/either'
  autoload :Left, 'functional/left'
  autoload :Right, 'functional/right'

  # rubocop: disable Style/MethodName
  def Option(value)
    if value.nil?
      None()
    else
      Some(value)
    end
  end

  def None
    None.new
  end

  def Some(value)
    Some.new(value)
  end

  # Constructs a `Try` using the block. This
  # method will ensure any non-fatal exception is caught and a
  # `Failure` object is returned.
  #
  def Try
    Success(yield)
  rescue StandardError => error
    Failure(error)
  end

  def Failure(exception)
    Failure.new(exception)
  end

  def Success(value)
    Success.new(value)
  end

  def Future(opts = {}, &block)
    Future.new(opts, &block)
  end

  def Left(value)
    Left.new(value)
  end

  def Right(value)
    Right.new(value)
  end
  # rubocop: enable Style/MethodName
end
