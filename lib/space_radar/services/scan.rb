module SpaceRadar
  module Services
    # +SpaceRadar::Services::Scan+ finds the known patterns
    # inside the radar scan data pattern with the provided accuracy degree
    class Scan
      MINIMUM_EDGE_CHARS = 3 # minimum size of a known item's crop

      attr_accessor :accuracy

      # @param radar_scan [SpaceRadar::Pattern] - radar scan data pattern
      # @param known_items [Array] - array of SpaceRadar::Pattern instances
      # representing the known items to be found
      # @param accuracy [Integer] - pattern match accuracy
      def initialize(radar_scan, known_items, accuracy = 80)
        @radar_scan = radar_scan
        @known_items = known_items
        @accuracy = accuracy
        @result_collector = ResultsCollect.new
      end

      def run
        @known_items.each do |item|
          next if item.width > @radar_scan.width ||
                  item.height > @radar_scan.height

          scan_horizontal_edge(item, :top)
          scan_horizontal_edge(item, :bottom)
          scan_vertical_edge(item, :left)
          scan_vertical_edge(item, :right)
          scan_interior_area(item)
        end

        results
      end

      def results
        @result_collector.results
      end

      private

      # Find the known items that fit entirely inside the radar scan
      # @param item [SpaceRadar::Pattern] - pattern to be found
      def scan_interior_area(item)
        (0..@radar_scan.width - item.width - 1).each do |x_pos|
          (0..@radar_scan.height - item.height - 1).each do |y_pos|
            next if @result_collector.existing_result?(x_pos, y_pos)

            match_result(item, x_pos, y_pos)
          end
        end
      end

      # Find horizontally cropped portions of the known items
      # on the horizontal edges of the radar scan
      # @param item [SpaceRadar::Pattern] - pattern to be found
      # @param edge [Enum] - edge of the radar scan pattern.
      # Possible values: :top, :bottom
      def scan_horizontal_edge(item, edge = :top)
        return if item.height < MINIMUM_EDGE_CHARS

        (MINIMUM_EDGE_CHARS..item.height - 1).each do |area_height|
          item_crop_method = edge == :top ? :last : :first
          y_pos = edge == :top ? 0 : @radar_scan.height - area_height
          partial_item = Pattern.new(item.signature.send(item_crop_method, area_height))

          (0..@radar_scan.width - item.width).each do |x_pos|
            next if @result_collector.existing_result?(x_pos, y_pos)

            match_result(partial_item, x_pos, y_pos)
          end
        end
      end

      # Find vertically cropped portions of the known items
      # on the vertical edges of the radar scan
      # @param item [SpaceRadar::Pattern] - pattern to be found
      # @param edge [Enum] - edge of the radar scan pattern.
      # Possible values: :left, :right
      def scan_vertical_edge(item, edge = :left)
        return if item.width < MINIMUM_EDGE_CHARS

        (MINIMUM_EDGE_CHARS..item.width - 1).each do |area_width|
          item_crop_method = edge == :left ? :last : :first
          x_pos = edge == :left ? 0 : @radar_scan.width - area_width
          signature = item.signature.map do |line|
            line.split(//).send(item_crop_method, area_width).join
          end
          partial_item = Pattern.new(signature)

          (0..@radar_scan.height - item.height).each do |y_pos|
            next if @result_collector.existing_result?(x_pos, y_pos)

            match_result(partial_item, x_pos, y_pos)
          end
        end
      end

      # Match a known item against a portion of the radar scan pattern
      # @param item [SpaceRadar::Pattern] - pattern to be found
      # @param x_pos [Int] - X position on tre radar scan pattern
      # @param y_pos [Int] - Y position on tre radar scan pattern
      def match_result(item, x_pos, y_pos)
        scan_area = get_scan_area(x_pos, y_pos, item.width, item.height)
        match = item.match(scan_area)
        return unless match >= @accuracy

        next_x_pos, next_match = scan_proximity(item, match, x_pos, y_pos)
        @result_collector.run(item, next_x_pos, y_pos, next_match)
      end

      # Scan the proximity of a found item for a better match
      # @param item [SpaceRadar::Pattern] - pattern to be found
      # @param match [Float] - the match value of the found item
      # @param x_pos [Int] - X position on tre radar scan pattern
      # @param y_pos [Int] - Y position on tre radar scan pattern
      def scan_proximity(item, match, x_pos, y_pos)
        best_match = match
        best_x_pos = x_pos
        (x_pos + 1..x_pos + 2).each do |next_x_pos|
          scan_area = get_scan_area(next_x_pos, y_pos, item.width, item.height)
          next_match = item.match(scan_area)
          if next_match > best_match
            best_x_pos = next_x_pos
            best_match = next_match
          end
        end
        [best_x_pos, best_match]
      end

      # Crop a portion of the radar scan pattern
      def get_scan_area(x_pos, y_pos, width, height)
        lines = @radar_scan.signature[y_pos..y_pos + height - 1].map do |line|
          line[x_pos..x_pos + width - 1]
        end
        Pattern.new(lines)
      end

      # +SpaceRadar::Services::Scan::ResultsCollect+ stores the found items
      class ResultsCollect
        attr_reader :results

        def initialize
          @results = []
          @results_cahce = []
        end

        def run(item, x_pos, y_pos, match)
          @results << { item: item, x: x_pos, y: y_pos, match: match }
          (x_pos - 1..x_pos + item.width).each do |x|
            (y_pos - 1..y_pos + item.height).each do |y|
              @results_cahce << "#{x}:#{y}"
            end
          end
        end

        # Check if there's an item found already on the given position
        # of the radar scan pattern
        def existing_result?(x_pos, y_pos)
          @results_cahce.include?("#{x_pos}:#{y_pos}")
        end
      end
    end
  end
end
