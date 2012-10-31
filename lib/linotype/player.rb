module Linotype
  class Player
    
    DEFAULT_STRATEGY = ->(move) { (move.score[:defended] * 2) + move.score[:covered] }

    attr_accessor :strategy

    def initialize(args={})
      args = { strategy: DEFAULT_STRATEGY }.merge(args)
      self.strategy = args[:strategy]
    end
    
  end
end