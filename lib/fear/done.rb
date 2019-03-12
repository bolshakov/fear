module Fear
  # Typically used to signal completion but there is no actual value completed.
  #
  # @example
  #   if user.valid?
  #     Fear.right(Done)
  #   else
  #     Fear.left(user.errors)
  #   end
  #
  Done = Object.new.tap do |done|
    # @return [String]
    def done.to_s
      '#<Fear::Done>'
    end

    # @return [String]
    def done.inspect
      '#<Fear::Done>'
    end
  end.freeze
end
