module SpaceRadar
  module Services
    class Scan
      # +SpaceRadar::Services::Scan::ResultsCollect+ stores the found items
      class ResultsCollect
        attr_reader :results

        def initialize
          @results = []
          @results_cache = []
        end

        def run(item, x_pos, y_pos, match)
          @results << { item: item, x: x_pos, y: y_pos, match: match }
          (x_pos..x_pos + item.width).each do |x|
            (y_pos..y_pos + item.height).each do |y|
              @results_cache << "#{x}:#{y}"
            end
          end
        end

        # Check if there's an item found already on the given position
        # of the radar scan pattern
        def existing_result?(x_pos, y_pos)
          @results_cache.include?("#{x_pos}:#{y_pos}")
        end
      end
    end
  end
end
