module SpaceRadar
  module Services
    # +SpaceRadar::Services::Pattern+ creates SpaceRadar::Pattern instances 
    # based on the provided data files
    class DataImport
      RADAR_SCAN_PATH = 'lib/space_radar/data/radar_scan.txt'.freeze
      KNOWN_ITEMS_DIR_PATH = 'lib/space_radar/data/known_items'.freeze

      attr_reader :radar_scan, :items

      # @param radar_scan_path [String] - path to the *.txt file
      # containing the raw data to be scanned
      # @param known_items_dir_path [String] - path to the folder containing
      # the *.txt files with the known patterns to be matched during scan
      def initialize(radar_scan_path: nil, known_items_dir_path: nil)
        @radar_scan_path = radar_scan_path || RADAR_SCAN_PATH
        @known_items_dir_path = known_items_dir_path || KNOWN_ITEMS_DIR_PATH
        @radar_scan = Pattern.new
        @items = []
      end

      def run
        import_radar_scan_data
        import_items_data
        validate_patterns_not_empty
        validate_items_within_radar_scan
      end

      private

      # Imports the radar scan data
      def import_radar_scan_data
        radar_data = File.read(@radar_scan_path).strip
        @radar_scan = Pattern.new(radar_data.strip.split(/\n/))
      rescue Errno::ENOENT
        raise ArgumentError,
              "Invalid radar_scan_path value: #{@radar_scan_path}"
      end

      # Imports the known patterns
      def import_items_data
        validate_items_data_path

        Dir["#{@known_items_dir_path}/*.txt"].each do |file|
          item_data = File.read(file).strip
          @items << Pattern.new(item_data.split(/\n/))
        end
      end

      def validate_items_data_path
        unless File.directory?(@known_items_dir_path)
          raise ArgumentError,
                "Invalid known_items_dir_path value: #{@known_items_dir_path}"
        end

        return if Dir["#{@known_items_dir_path}/*.txt"].any?

        raise ArgumentError,
              "The path #{@known_items_dir_path} contains no *.txt files"
      end

      def validate_patterns_not_empty
        return unless ([radar_scan] + items).select do |pattern|
          pattern.signature.empty?
        end.any?

        raise ArgumentError,
              'One or more provided data files are empty'
      end

      def validate_items_within_radar_scan
        max_item_width = items.map(&:width).max
        max_item_height = items.map(&:height).max

        if max_item_width > @radar_scan.width ||
           max_item_height > @radar_scan.height
          raise ArgumentError,
                'One or more known items\' dimensions exceed the radar scan dimensions'
        end
      end
    end
  end
end
