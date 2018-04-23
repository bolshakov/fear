module Fear
  # Typically used to signal completion but there is no actual value completed.
  #
  # @example
  #   if user.valid?
  #     Right(Done)
  #   else
  #     Left(user.errors)
  #   end
  #
  Done = Object.new.tap do |done|
    # @return [String]
    def done.to_s
      'Done'
    end

    # @return [String]
    def done.inspect
      'Done'
    end
  end.freeze
end
