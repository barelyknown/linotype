module Linotype
  class Simulator
    
    attr_accessor :player_one, :player_two, :game
    
    def initialize(strategy_one, strategy_two)
      self.player_one = Player.new(strategy: strategy_one)
      self.player_two = Player.new(strategy: strategy_two)
    end
    
    def simulate!
      self.game = Game.new(player_one: player_one, player_two: player_two)
      puts "Let's start the simulator"
      while !game.over?
        if best_next_play = game.best_next_play        
          puts "Player #{game.player_number(game.current_player)} will play: #{best_next_play.word}"
          game.play(*best_next_play.to_hash[:coordinates])
        else
          puts "Player #{game.player_number(game.current_player)} will pass."
          game.play
        end
        game.print_board
        game.print_scores
      end
      game
    end
    
  end
end