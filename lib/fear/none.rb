# frozen_string_literal: true

module Fear
  # The only instance of NoneClass
  None = NoneClass.new.freeze
  public_constant :None
end
