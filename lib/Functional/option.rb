module Functional
  module Option
  end

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
