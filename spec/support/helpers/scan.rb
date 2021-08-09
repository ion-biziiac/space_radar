module Helpers
  module Scan
    def build_scan_result(radar_scan, items)
      scanner = SpaceRadar::Services::Scan.new(
        radar_scan: radar_scan,
        known_items: items
      )
      scanner.run
    end

    def build_items_collect_result(item, scan_width, scan_height, x_pos, y_pos)
      collector = SpaceRadar::Services::Scan::ItemsCollect.new(
        item: item,
        scan_width: scan_width,
        scan_height: scan_height,
        x_pos: x_pos,
        y_pos: y_pos
      )
      collector.run
    end
  end
end
