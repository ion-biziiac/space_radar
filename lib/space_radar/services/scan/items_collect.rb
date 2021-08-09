module SpaceRadar
  module Services
    class Scan
      # +SpaceRadar::Services::Scan::ItemsCollect+ collects a known item
      # and all its cropped derivates that should be matched against the
      # radar scan pattern on a particular X/Y position of it
      class ItemsCollect
        attr_reader :items

        # @param item [SpaceRadar::Item] - base known item
        # @param scan_width [Int] - main scan area width
        # @param scan_height [Int] - main scan area height
        # @param x_pos [Int] - the X position on the main scan area
        # @param y_pos [Int] - the Y position on the main scan area
        def initialize(item:, scan_width:, scan_height:, x_pos:, y_pos:)
          @item = item
          @scan_width = scan_width
          @scan_height = scan_height
          @x_pos = x_pos
          @y_pos = y_pos
          @items = []
        end

        def run
          @items.clear

          top_edge_derivates
          right_edge_derivates
          bottom_edge_derivates
          left_edge_derivates
          top_left_corner_derivates
          top_right_corner_derivates
          bottom_right_corner_derivates
          bottom_left_corner_derivates
          main_item

          items
        end

        private

        # Adds the main item to the list if it fits within the scan area
        def main_item
          return if right_edge? || bottom_edge?

          @items << @item
        end

        # Collects the item derivates that should be matched against
        # the top edge of the radar scan pattern
        def top_edge_derivates
          return unless top_edge? && !right_edge?

          @items += @item.derivates[:top]
        end

        # Collects the item derivates that should be matched against
        # the top left corner of the radar scan pattern
        def top_left_corner_derivates
          return unless top_edge? && left_edge?

          @items += @item.derivates[:top_left]
        end

        # Collects the item derivates that should be matched against
        # the top right corner of the radar scan pattern
        def top_right_corner_derivates
          return unless top_edge? && right_edge?

          @items += @item.derivates[:top_right].select do |derivate|
            derivate.width == @scan_width - @x_pos
          end
        end

        # Collects the item derivates that should be matched against
        # the bottom edge of the radar scan pattern
        def bottom_edge_derivates
          return unless bottom_edge? && !right_edge?

          @items += @item.derivates[:bottom].select do |derivate|
            derivate.height == @scan_height - @y_pos
          end
        end

        # Collects the item derivates that should be matched against
        # the bottom left corner of the radar scan pattern
        def bottom_left_corner_derivates
          return unless bottom_edge? && left_edge?

          @items += @item.derivates[:bottom_left].select do |derivate|
            derivate.height == @scan_height - @y_pos
          end
        end

        # Collects the item derivates that should be matched against
        # the bottom right corner of the radar scan pattern
        def bottom_right_corner_derivates
          return unless bottom_edge? && right_edge?

          @items += @item.derivates[:bottom_right].select do |derivate|
            derivate.height == @scan_height - @y_pos &&
              derivate.width == @scan_width - @x_pos
          end
        end

        # Collects the item derivates that should be matched against
        # the left edge of the radar scan pattern
        def left_edge_derivates
          return unless left_edge? && !bottom_edge?

          @items += @item.derivates[:left]
        end

        # Collects the item derivates that should be matched against
        # the right edge of the radar scan pattern
        def right_edge_derivates
          return unless right_edge? && !bottom_edge?

          @items += @item.derivates[:right].select do |derivate|
            derivate.width == @scan_width - @x_pos
          end
        end

        def top_edge?
          @y_pos.zero?
        end

        def right_edge?
          @x_pos > @scan_width - @item.width
        end

        def bottom_edge?
          @y_pos > @scan_height - @item.height
        end

        def left_edge?
          @x_pos.zero?
        end
      end
    end
  end
end
