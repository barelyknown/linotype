module Linotype
  class Move
    
    attr_reader :game, :player, :invalid_reason
    
    def initialize(game, player, tiles)
      @game = game
      @player = player
      @tiles = tiles
      calculate_valid
    end
       
    def valid?
      !!@valid
    end
    
    def invalid?
      !valid?
    end
    
    def word
      @tiles.collect(&:letter).join
    end
    
    def pass?
      @tiles.empty?
    end
    
    def cover_tiles!
      @tiles.each { |tile| tile.covered_by = @player unless tile.defended? }
    end
    
    def to_hash
      {
        player: game.player_number(@player),
        word: word,
        valid: valid?,
        invalid_reason: @invalid_reason,
        player_sequence: game.valid_moves.select { |move| move.player == @player }.index(self).to_i + 1,
        total_sequence: game.valid_moves.index(self).to_i + 1
      }
    end
        
    def calculate_valid
      if pass?
        @valid = true
      elsif !uses_game_tiles?
        @invalid_reason = "does not use game tile letters"
      elsif !in_dictionary?
        @invalid_reason = "is not in dictionary"
      elsif !new_word_in_game?
        @invalid_reason = "has been played before"
      elsif !enough_characters?
        @invalid_reason = "is too short"
      elsif prefix_of_previous_word?
        @invalid_reason = "is a prefix of a previously played word"
      else
        @valid = true
      end
    end
        
    def in_dictionary?
      game.dictionary.valid?(word)
    end
    
    def uses_game_tiles?
      letters = game.letters
      word.each_char { |letter| return false unless letters.delete(letter) }
    end
    
    def new_word_in_game?
      !game.valid_moves.collect(&:word).include?(word)
    end
    
    def enough_characters?
      word.length >= 2
    end
    
    def prefix_of_previous_word?
      game.valid_moves.find { |move| move.word =~ /\A#{word}/ }
    end
                
  end
end