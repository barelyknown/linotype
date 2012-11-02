module Linotype
  class Game
        
    attr_accessor :moves
    attr_reader :current_player, :players

    def initialize(args={})
      args = { player_one: Player.new, player_two: Player.new }.merge(args)
      @board = Board.new(self, tiles: create_tile_letter_array(args[:tiles]))
      @players = [args[:player_one], args[:player_two]]
      @current_player = @players[0]
      @moves = []
    end
    
    def create_tile_letter_array(letter_arg)
      case letter_arg
      when nil
        Board.new_random_letters
      when Array
        letter_arg
      when String
        square_size = Math.sqrt(letter_arg.length).ceil
        letter_array = [[]]
        letter_arg.each_char do |letter|
          letter_array << [] if letter_array.last.size == square_size
          letter_array.last << letter.upcase
        end
        letter_array
      end
    end
            
    def play(*tile_coordinates)
      tiles = find_tiles(tile_coordinates)
      Move.new(self, @current_player, tiles).valid?
    end
    
    def every_play_for_word(word)
      tiles_per_letter = {}
      word.chars.to_a.uniq.each do |unique_letter|
        tiles_per_letter[unique_letter] = []
        tile_rows.flatten.select { |tile| tile.letter == unique_letter }.each do |matching_tile|
          tiles_per_letter[unique_letter] << matching_tile
        end
      end
      variations = tiles_per_letter.values.inject(1) { |vars, tiles| tiles.count * vars }
      plays = []
      v = 0
      variations.times { plays << []; v += 1 }
      word.chars.each do |letter|
        play_number = 0
        repetitions = variations / tiles_per_letter[letter].count
        tiles_per_letter[letter].each do |tile|
          repetitions.times do
            plays[play_number] << tile
            play_number += 1
          end
        end
      end
      plays.select { |play| play.uniq.count == play.count }
    end
    
    def test_potential_plays
      potential_moves = []
      remaining_plays.each do |word_to_test|
        every_play_for_word(word_to_test).each do |tiles|
          move = Move.new(self, @current_player, tiles)
          potential_moves << move
          move.undo!
        end
      end
      potential_moves
    end
    
    def previously_played_words
      moves.collect(&:word)
    end
    
    def remaining_plays
      potential_plays - previously_played_words
    end
    
    def valid_potential_plays
      test_potential_plays.select { |potential_play| potential_play.valid? }
    end
    
    def best_next_play
      valid_potential_plays.sort do |a, b|
        current_player.strategy.score(b) <=> current_player.strategy.score(a)
      end.first
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
    
    def player_number(player)
      @players.index(player) + 1
    end
    
    def score(player)
      covered_tiles(player).count
    end
    
    def potential_plays(remaining_letters=letters)
      @potential_plays ||= calc_potential_plays(remaining_letters)
    end
    
    def calc_potential_plays(remaining_letters)
      plays = []
      letter_group = letters.group_by { |l| l }
      dictionary.words.each do |word|
        if word_match(letter_group, word)
          plays << word
        end
      end
      plays
    end
    
    def word_match(letter_group, word)
      word_letter_group = word.chars.to_a.group_by { |c| c }
      word.each_char do |letter|
        return false unless (letter_group[letter] && letter_group[letter].count >= word_letter_group[letter].count)
      end
      true
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
    
    def all_tiles
      tile_rows.flatten
    end

    def letters
      @board.tiles.flatten.collect(&:letter)
    end

    def other_player
      @players.index(@current_player) == 0 ? @players[1] : @players[0]
    end
        
    def find_tiles(tile_coordinates)
      return [] if tile_coordinates.empty?
      tile_coordinates.collect do |tile_coordinate|
        tile = tile_rows[tile_coordinate[0]][tile_coordinate[1]]
        raise ArgumentError, "The board does not have a tile at that location" unless tile
        tile
      end
    end
    private :find_tiles
    
    def toggle_current_player
      @current_player = other_player
    end
    
    def uncovered_tiles
      all_tiles.select { |tile| !tile.covered_by }
    end
        
    def defended_tiles(player)
      tile_rows.flatten.select { |tile| player && tile.covered_by == player && tile.defended? }
    end
    
    def covered_tiles(player)
      tile_rows.flatten.select { |tile| player && tile.covered_by == player }
    end
    
    def edge_tiles(player)
      tile_rows.flatten.select { |tile| player && tile.edge? && tile.covered_by == player }
    end
    
    def corner_tiles(player)
      tile_rows.flatten.select { |tile| player && tile.corner? && tile.covered_by == player }
    end
    
    def two_passes_in_a_row?
      valid_moves.count >= 2 && valid_moves[-2,2].select { |move| move.pass? }.count == 2
    end
    private :two_passes_in_a_row?
    
    def print_board
      tile_rows.each do |row|
        r = ""
        row.each do |tile|
          r << "#{tile.letter}#{tile.covered_by ? player_number(tile.covered_by) : ' '} "
        end
        puts r
      end
    end
    
    def print_scores
      players.each { |player| puts "Player #{player_number(player)}: #{covered_tiles(player).count}" }
    end
    
  end
end