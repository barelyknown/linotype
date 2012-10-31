module Linotype
  class Strategy
    
    EDGE_AND_CORNER = ->(move) do
      score = move.score[:covered] + move.score[:defended] + move.score[:edges] + move.score[:corners]
      score += 100000 if move.score[:remaining_uncovered_after] == 0
      score
    end
    
    CORNER_LOVER = ->(move) do
      score = move.score[:covered] + move.score[:defended] + move.score[:edges] + move.score[:corners]
      score += 10 if (move.score[:corners_defended_before] == 0 && move.score[:corners_defended_after] > 0)
      score += 100000 if move.score[:remaining_uncovered_after] == 0
      score
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
    
    def self.predefined(strategy_name)
      new(const_get(strategy_name))
    end
    
  end
end