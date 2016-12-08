require 'dry-equalizer'
require 'functional/version'

module Functional
  Error = Class.new(StandardError)
  IllegalStateException = Class.new(Error)
  NoSuchElementError = Class.new(Error)

  autoload :For, 'functional/for'
  autoload :Utils, 'functional/utils'
  autoload :RightBiased, 'functional/right_biased'

  autoload :Option, 'functional/option'
  autoload :Some, 'functional/some'
  autoload :None, 'functional/none'

  autoload :Try, 'functional/try'
  autoload :Success, 'functional/success'
  autoload :Failure, 'functional/failure'

  autoload :Either, 'functional/either'
  autoload :Left, 'functional/left'
  autoload :Right, 'functional/right'

  module Mixin
    include Either::Mixin
    include For::Mixin
    include Option::Mixin
    include Try::Mixin
  end
end
