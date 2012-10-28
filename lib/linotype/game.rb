module Linotype
  class Game
        
    def initialize
      @board = Board.new_random(self)
      @players = [Player.new, Player.new]
      @current_player = @players[0]
      @moves = []
    end
        
    def play(*tile_coordinates)
      tiles = find_tiles(tile_coordinates)
      move = Move.new(self, @current_player, tiles)
      if move.valid?
        move.cover_tiles!
        toggle_current_player
      end
      @moves << move
      @current_player == move.player ? false : true
    end

    def over?
      uncovered_tiles.empty? || two_passes_in_a_row?
    end
    
    def winner
      scores.inject(nil) { |winner, p| p[1] > winner.to_i ? p[0] : winner } if over?
    end

    def scores
      @players.inject({}) { |scores, player| scores[player_number(player)] = score(player); scores }
    end

    def board
      tile_rows.collect { |row| row.collect { |tile| tile.to_hash } }
    end
    
    def moves
      @moves.collect { |move| move.to_hash }
    end

    def player_number(player)
      @players.index(player) + 1
    end
    
    def score(player)
      covered_tiles(player).count
    end

    def valid_moves
      @moves.select(&:valid?)
    end
    
    def invalid_moves
      @moves.select(&:invalid?)
    end
    
    def dictionary
      Linotype::Dictionary.loaded
    end

    def tile_rows
      @board.tiles
    end

    def letters
      @board.tiles.flatten.collect(&:letter)
    end

    def other_player
      @players.index(@current_player) == 0 ? @players[1] : @players[0]
    end
    private :other_player
        
    def find_tiles(tile_coordinates)
      tile_coordinates.collect do |tile_coordinate|
        tile = tile_rows[tile_coordinate[:row]][tile_coordinate[:column]]
        raise ArgumentError, "The board does not have a tile at that location" unless tile
        tile
      end
    end
    private :find_tiles
    
    def toggle_current_player
      @current_player = other_player
    end
    private :toggle_current_player
    
    
    def uncovered_tiles
      covered_tiles(nil)
    end
    private :uncovered_tiles
    
    def covered_tiles(player)
      tile_rows.flatten.select { |tile| tile.covered_by == player }
    end
    private :covered_tiles
    
    def two_passes_in_a_row?
      valid_moves.count >= 2 && valid_moves[-2,2].select { |move| move.pass? }.count == 2
    end
    private :two_passes_in_a_row?
    
  end
end