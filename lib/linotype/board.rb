module Linotype
  class Board  
  
    attr_accessor :tiles
    attr_reader :game
  
    def initialize(game, args={})
      @game = game
      @tiles = args[:tiles].collect { |row| row.collect { |tile|  Tile.new(self, tile) } }
    end
        
    def self.new_random(game, rows=5, columns=5)
      new(game, tiles: rows.times.collect { columns.times.collect { ('A'..'Z').to_a[rand(0..25)] } })
    end

    def row_count
      @row_count ||= tiles.count
    end

    def column_count 
      @column_count ||= tiles.first.count
    end
    
    def row(tile)
      row_number = 0
      tiles.each do |row|
        return row_number if row.include?(tile)
        row_number += 1
      end
    end
    
    def column(tile)
      tiles[row(tile)].index(tile)
    end
      
  end
end
