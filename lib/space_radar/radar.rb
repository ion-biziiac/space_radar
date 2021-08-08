require 'getoptlong'

module SpaceRadar
  # +SpaceRadar::Radar+ parses the given data path arguments and
  # runs the SpaceRadar::Services::Scan service against the obtained patterns
  class Radar
    MATCH_ACCURACY = 80
    attr_reader :results

    def initialize
      @radar_scan = nil
      @known_items = nil
      @results = []
    end

    # Run the radar scanner
    def scan
      @radar_scan, @known_items = import_data
      @results = Services::Scan.new(
        @radar_scan,
        @known_items,
        MATCH_ACCURACY
      ).run
    rescue ArgumentError => e
      puts "Error: #{e.message}"
    end

    # Draw on screen the radar scanner results
    def draw
      return unless @radar_scan && @known_items

      screen = Array.new(@radar_scan.height)
      screen.each_index do |i|
        screen[i] = Array.new(@radar_scan.width, '-').join('')
      end

      results.each do |result|
        result[:item].signature.each_with_index do |line, line_y|
          row_index = result[:y] + line_y
          char_index_range = result[:x]..result[:x] + result[:item].width - 1
          screen[row_index][char_index_range] = line
        end
      end

      puts "\033[0;32m"
      puts screen.join("\n")
    end

    private

    # Fetch and instantiate the pattterns using the DataImport service
    def import_data
      options = fetch_options
      radar_scan_path = options['--radar-scan-path']
      known_items_dir_path = options['--known-items-dir-path']

      data_importer = Services::DataImport.new(
        radar_scan_path: radar_scan_path,
        known_items_dir_path: known_items_dir_path
      )
      data_importer.run

      [data_importer.radar_scan, data_importer.items]
    end

    # Read the coomand line options
    def fetch_options
      options = {}
      opts = GetoptLong.new(
        ['--radar-scan-path', GetoptLong::REQUIRED_ARGUMENT],
        ['--known-items-dir-path', GetoptLong::REQUIRED_ARGUMENT],
        ['--help', GetoptLong::NO_ARGUMENT]
      )
      opts.each do |opt, arg|
        options[opt] = arg
      end

      if options['--help']
        puts 'Usage: bin/space-radar [--radar-scan-path FILE] [--known-items-dir-path FOLDER]'
        puts 'The data files need to have the \'txt\' extension.'
        puts 'The default data will be used if no paths given.'
        exit 0
      end

      options
    end
  end
end
