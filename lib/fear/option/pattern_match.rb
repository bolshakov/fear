require 'qo'

module Fear
  module Option
    SomeBranch = Qo.create_branch(
      name: 'some',
      precondition: ->(v) { !v.empty? },
      extractor: :get,
    )

    private_constant :SomeBranch

    NoneBranch = Qo.create_branch(
      name: 'none',
      precondition: ->(v) { v.empty? },
    )

    private_constant :NoneBranch

    PatternMatch = Qo.create_pattern_match(
      branches: [
        SomeBranch,
        NoneBranch,
      ],
    ).prepend(ExhaustivePatternMatch)

    private_constant :PatternMatch
  end
end
