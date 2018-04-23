require 'dry-equalizer'
require 'fear/version'

module Fear
  Error = Class.new(StandardError)
  IllegalStateException = Class.new(Error)
  NoSuchElementError = Class.new(Error)

  autoload :Done, 'fear/done'
  autoload :For, 'fear/for'
  autoload :RightBiased, 'fear/right_biased'
  autoload :Utils, 'fear/utils'

  autoload :Option, 'fear/option'
  autoload :Some, 'fear/some'
  autoload :None, 'fear/none'

  autoload :Try, 'fear/try'
  autoload :Success, 'fear/success'
  autoload :Failure, 'fear/failure'

  autoload :Either, 'fear/either'
  autoload :Left, 'fear/left'
  autoload :Right, 'fear/right'

  module Mixin
    include Either::Mixin
    include For::Mixin
    include Option::Mixin
    include Try::Mixin
  end
end
