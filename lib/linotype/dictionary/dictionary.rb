require 'set'

module Linotype
  class Dictionary
    
    class << self
      def loaded
        @loaded ||= new
      end
    end
    
    attr_accessor :words

    def initialize
      @words = Set.new(File.open(words_path).readlines.collect { |word| word.upcase.chomp })
    end
    
    def words_path
      File.dirname(__FILE__) + "/words.txt"
    end
    
    def valid?(word)
      words.include?(word.upcase)
    end
    
  end
end