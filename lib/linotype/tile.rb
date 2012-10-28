module Linotype
  class Tile
    
    attr_accessor :covered_by
    attr_reader :letter
    
    def initialize(board, letter=random_letter)
      @board = board
      @letter = letter
    end
    
    def to_hash
      {
        letter:     @letter,
        row:        row,
        column:     column,
        covered_by: (game.player_number(covered_by) if covered_by),
        defended:   defended?
      }
    end
    
    def game
      @board.game
    end
    
    def random_letter
      ('A'..'Z').to_a[rand(0..25)]
    end
    
    def row
      @row ||= @board.row(self)
    end
    
    def column
      @column ||= @board.column(self)
    end
    
    def previous?(coordinate_type)
      send(coordinate_type) > 0
    end
    
    def next?(coordinate_type)
      send(coordinate_type) < @board.send("#{coordinate_type}_count") - 1
    end
    
    def adjacent_tiles
      @adjacent_tiles ||= calculate_adjacent_tiles
    end
        
    def defended?
      adjacent_tiles.select { |tile| tile.covered_by == covered_by && covered_by }.count == adjacent_tiles.count
    end
    
    def calculate_adjacent_tiles
      @adjacent_tiles = []
      @adjacent_tiles << @board.tiles[row - 1][column] if previous?(:row)
      @adjacent_tiles << @board.tiles[row + 1][column] if next?(:row)
      @adjacent_tiles << @board.tiles[row][column - 1] if previous?(:column)
      @adjacent_tiles << @board.tiles[row][column + 1] if next?(:column)
      @adjacent_tiles
    end
  end
end