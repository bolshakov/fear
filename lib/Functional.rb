require 'functional/version'

module Functional
  autoload :Option, 'functional/option'
  autoload :Some, 'functional/some'
  autoload :None, 'functional/none'

  def Option(value)
    if value == nil
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
end
