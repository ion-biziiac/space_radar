module SpaceRadar
  module Services
    # +SpaceRadar::Services::ScreenDraw+ outputs the radar screen
    # based on a list of found items provided by SpaceRadar::Services::Scan::ResultsCollect
    class ScreenDraw
      def initialize(results:, width:, height:)
        @results = results
        @width = width
        @height = height
      end

      def run
        puts "\033[0;32m"
        puts build_output
      end

      private

      def build_output
        screen = blank_screen

        @results.each do |result|
          result[:item].signature.each_with_index do |line, line_y|
            row_index = result[:y] + line_y
            char_index_range = result[:x]..result[:x] + result[:item].width - 1
            screen[row_index][char_index_range] = line
          end
        end

        screen.join("\n")
      end

      def blank_screen
        screen = Array.new(@height)
        screen.each_index do |index|
          screen[index] = Array.new(@width, '-').join('')
        end

        screen
      end
    end
  end
end
