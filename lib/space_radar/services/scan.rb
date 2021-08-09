module SpaceRadar
  module Services
    # +SpaceRadar::Services::Scan+ finds the known patterns
    # inside the radar scan data pattern with the provided accuracy degree
    class Scan
      attr_accessor :accuracy

      # @param radar_scan [SpaceRadar::Pattern] - radar scan data pattern
      # @param known_items [Array] - array of SpaceRadar::Pattern instances
      # representing the known items to be found
      # @param accuracy [Integer] - pattern match accuracy
      def initialize(radar_scan:, known_items:, accuracy: 80)
        @radar_scan = radar_scan
        @known_items = known_items
        @accuracy = accuracy
        @result_collector = ResultsCollect.new
      end

      def run
        (0..@radar_scan.height - 1).each do |y_pos|
          (0..@radar_scan.width - 1).each do |x_pos|
            scan(x_pos, y_pos)
          end
        end

        results
      end

      def results
        @result_collector.results
      end

      private

      # Finds the known items alongside with their cropped derivates
      # @param x_pos [Int] - X position on the radar scan pattern
      # @param y_pos [Int] - Y position on the radar scan pattern
      def scan(x_pos, y_pos)
        items = collect_items(x_pos, y_pos)
        return if items.size.zero?

        items.each do |item|
          next if @result_collector.existing_result?(x_pos, y_pos)

          match_result(item, x_pos, y_pos)
        end
      end

      # Collects known items and their cropped derivates applicable
      # for a certain position on the radar scan pattern
      # @param x_pos [Int] - X position on the radar scan pattern
      # @param y_pos [Int] - Y position on the radar scan pattern
      def collect_items(x_pos, y_pos)
        @known_items.map do |base_item|
          ItemsCollect.new(
            item: base_item,
            scan_width: @radar_scan.width,
            scan_height: @radar_scan.height,
            x_pos: x_pos,
            y_pos: y_pos
          ).run
        end.flatten.compact
      end

      # Match a known item against a portion of the radar scan pattern
      # @param item [SpaceRadar::Pattern] - pattern to be found
      # @param x_pos [Int] - X position on tre radar scan pattern
      # @param y_pos [Int] - Y position on tre radar scan pattern
      def match_result(item, x_pos, y_pos)
        scan_area = @radar_scan.crop(x_pos, y_pos, item.width, item.height)
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
        (x_pos + 1..x_pos + 2).each do |next_x_pos|
          scan_area = @radar_scan.crop(next_x_pos, y_pos, item.width, item.height)
          next_match = item.match(scan_area)
          if next_match > match
            x_pos = next_x_pos
            match = next_match
          end
        end

        [x_pos, match]
      end
    end
  end
end
