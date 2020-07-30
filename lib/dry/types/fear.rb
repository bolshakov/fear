# frozen_string_literal: true

require "dry/types"
require "fear"

Dry::Types.register_extension(:fear_option) do
  require "dry/types/fear/option"
end
