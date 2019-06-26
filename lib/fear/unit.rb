# typed: false
module Fear
  # Represents lack of value. It's typically returned when function completed without a value.
  #
  # @example
  #   if user.valid?
  #     Fear.right(Fear::Unit)
  #   else
  #     Fear.left(user.errors)
  #   end
  #
  # @example
  #   def sent_notifications(user)
  #     # ...
  #     Fear::Unit
  #   end
  #
  Unit = Object.new.tap do |unit|
    # @return [String]
    def unit.to_s
      '#<Fear::Unit>'
    end

    # @return [String]
    def unit.inspect
      '#<Fear::Unit>'
    end
  end.freeze
end
