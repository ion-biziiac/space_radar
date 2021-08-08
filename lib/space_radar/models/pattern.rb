require 'vladlev'

module SpaceRadar
  # +SpaceRadar::Pattern+ represents an ASCII pattern of X lines and Y columns
  class Pattern
    attr_reader :signature

    # @param signature [Array] - array of strings representing the pattern signature
    def initialize(signature = [])
      @signature = signature
    end

    # @return [String] - pattern signature represented as a single string
    def signature_string
      @signature_string ||= signature.join('')
    end

    # @return [Int] - pattern width
    def width
      @width ||= signature.first&.length || 0
    end

    # @return [Int] - pattern height
    def height
      @height ||= signature.size
    end

    # Matches the pattern signature with another pattern's signature
    # @param pattern [SpaceRadar::Pattern] - pattern to compare with
    # @return [Float] - percentage of patterns similarity
    def match(pattern)
      # Vladlev.distance is a custom fast implementation of the
      # Levenshtein Distance algorythm https://github.com/mxenabled/vladlev
      # This algorythm calculates the number of single character transformations
      # that need to be done to a string in order to make it match another string.
      signature_size = signature_string.length
      distance = Vladlev.distance(
        signature_string,
        pattern.signature_string
      )
      ((signature_size - distance).to_f / signature_size * 100).round(2)
    end
  end
end
