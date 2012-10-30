module Linotype
  class Move
    
    attr_reader :game, :player, :invalid_reason, :score
    
    def initialize(game, player, tiles)
      @game = game
      @player = player
      @tiles = tiles
      calculate_valid
      if valid?
        calculate_scores(:before)
        cover_tiles!
        calculate_scores(:after)
        calculate_net_scores
        @game.toggle_current_player
      end
      @game.moves << self
    end
    
    def score
      @score ||= {}
    end
        
    def calculate_scores(time)
      score["defended_#{time}".to_sym] = @game.defended_tiles(player).count
      score["covered_#{time}".to_sym] = @game.covered_tiles(player).count
    end
    
    def calculate_net_scores
      score[:defended] = score[:defended_after] - score[:defended_before]
      score[:covered] = score[:covered_after] - score[:covered_before]
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
      @previously_defended_tiles = @tiles.select { |tile| tile.defended? }
      (@tiles - @previously_defended_tiles).each { |tile| tile.covered_by = @player }
    end
    
    def uncover_tiles!
      (@tiles - @previously_defended_tiles).each { |tile| tile.covered_by = nil }
    end
    
    def to_hash
      {
        player: game.player_number(@player),
        word: word,
        valid: valid?,
        coordinates: @tiles.collect(&:to_a),
        invalid_reason: @invalid_reason,
        player_sequence: game.valid_moves.select { |move| move.player == @player }.index(self).to_i + 1,
        total_sequence: game.valid_moves.index(self).to_i + 1,
        score: score
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