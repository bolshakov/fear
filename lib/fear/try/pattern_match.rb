require 'qo'

module Fear
  module Try
    SuccessBranch = Qo.create_branch(
      name: 'success',
      precondition: :success?,
      extractor: :get,
    )

    private_constant :SuccessBranch

    FailureBranch = Qo.create_branch(
      name: 'failure',
      precondition: :failure?,
      extractor: :exception,
    )

    private_constant :FailureBranch

    PatternMatch = Qo.create_pattern_match(
      branches: [
        SuccessBranch,
        FailureBranch,
      ],
    ).prepend(ExhaustivePatternMatch)

    private_constant :PatternMatch
  end
end
