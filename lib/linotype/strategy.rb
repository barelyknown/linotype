module Linotype
  class Strategy
    
    LETTERPRESS_FAN_HEURISTIC = ->(move) do
      move.score[:covered] + move.score[:defended] + move.score[:edges] + move.score[:corners]
    end
    
    MAX_SIX_LETTERS = ->(move) do
      move.word.length <= 6 ? move.word.length + move.score[:covered] : 0
    end
    
    MAX_FIVE_LETTERS = ->(move) do
      move.word.length <= 5 ? move.word.length + move.score[:covered] : 0
    end
    
    MAX_THREE_LETTERS = ->(move) do
      move.word.length <= 3 ? move.word.length + move.score[:covered] : 0
    end    
    
    attr_accessor :scoring_algorithm
    
    def initialize(scoring_algorithm)
      self.scoring_algorithm = scoring_algorithm
    end
    
    def score(move)
      scoring_algorithm.call move
    end
    
  end
end