require 'functional/version'

module Functional
  IllegalStateException = Class.new(StandardError)

  autoload :Option, 'functional/option'
  autoload :Some, 'functional/some'
  autoload :None, 'functional/none'
  autoload :Try, 'functional/try'
  autoload :Success, 'functional/success'
  autoload :Failure, 'functional/failure'
  autoload :Future, 'functional/future'
  autoload :Promise, 'functional/promise'

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
  def Try(&block)
    Success(block.call)
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
end
