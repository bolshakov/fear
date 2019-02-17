require 'qo'

module Fear
  module Either
    RightBranch = Qo.create_branch(
      name: 'right',
      precondition: :right?,
      extractor: ->(e) { e.send(:value) },
    )

    private_constant :RightBranch

    LeftBranch = Qo.create_branch(
      name: 'left',
      precondition: :left?,
      extractor: ->(e) { e.send(:value) },
    )

    private_constant :LeftBranch

    PatternMatch = Qo.create_pattern_match(
      branches: [
        RightBranch,
        LeftBranch,
      ],
    ).prepend(ExhaustivePatternMatch)

    private_constant :PatternMatch
  end
end
