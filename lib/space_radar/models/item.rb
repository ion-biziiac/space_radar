module SpaceRadar
  # +SpaceRadar::Item+ represents a known item pattern or a cropped portion
  # of a known item pattern.
  class Item < Pattern
    MINIMUM_EDGE_CHARS = 3 # minimum size of a pattern signature crop

    # Generates a list of cropped derivates of the same item to be
    # matched against the main radar scan pattern on the corner
    # or edge sides of it (e.g. cropped signatures of 3x3, 3x4, 4x3, 4x5, etc.)
    def derivates
      @derivates ||= corner_derivates
                     .merge(horizontal_edge_derivates)
                     .merge(vertical_edge_derivates)
    end

    private

    # Generates corner derivates
    def corner_derivates
      %i[top_left top_right bottom_right bottom_left].map do |corner|
        [
          corner,
          generate_derivates(
            derivate_area_widths,
            derivate_area_heights,
            corner
          )
        ]
      end.to_h
    end

    # Generates top and bottom edge derivates
    def horizontal_edge_derivates
      %i[top bottom].map do |edge|
        [
          edge,
          generate_derivates([width], derivate_area_heights, edge)
        ]
      end.to_h
    end

    # Generates left and right edge derivates
    def vertical_edge_derivates
      %i[left right].map do |edge|
        [
          edge,
          generate_derivates(derivate_area_widths, [height], edge)
        ]
      end.to_h
    end

    # Helper method that generates new Item instances based on the
    # crop arguments
    # @param widths [Array] - a list of Int values representing the crop widths
    # @param heights [Array] - a list of Int values representing the crop heights
    # @param edge_position [Enum] - the position to start counting of
    # rows/cols to be cropped. Possible values: :top, :right, :bottom, :left,
    # :top_left, :top_right, :bottom_right, :bottom_left
    def generate_derivates(widths, heights, edge_position = :top)
      derivates = []
      heights.each do |area_height|
        widths.each do |area_width|
          derivates << crop_edge(
            area_height,
            area_width,
            edge_position
          )
        end
      end

      derivates
    end

    # Crops an item's pattern signature given the dimensions and
    # edge position. It is different from Pattern#crop, this method always
    # starts from the edges and does not make an inner crop.
    # @param rows [Int] - the number of rows to be cropped
    # @param cols [Int] - the number of cols to be cropped
    # @param edge_position [Enum] - the position to start counting of
    # rows/cols to be cropped. Possible values: :top, :right, :bottom, :left,
    # :top_left, :top_right, :bottom_right, :bottom_left
    def crop_edge(rows = 0, cols = 0, edge_position = :top)
      return self if height < rows || width < cols

      vertical_cut = edge_position.match(/top/) ? :last : :first
      horizontal_cut = edge_position.match(/left/) ? :last : :first
      output_signature = signature.dup
      output_signature = output_signature.send(vertical_cut, rows)
      output_signature = output_signature.map do |line|
        line.split(//).send(horizontal_cut, cols).join
      end

      self.class.new(output_signature)
    end

    # Generates possible widths of cropped item signature partials
    # based on the base item width and the minimum chars allowed for
    # a cropped partial
    def derivate_area_widths
      @derivate_area_widths ||=
        can_crop_horizontally? ? MINIMUM_EDGE_CHARS..width - 1 : []
    end

    # Generates possible heights of cropped item signature partials
    # based on the base item height and the minimum chars allowed for
    # a cropped partial
    def derivate_area_heights
      @derivate_area_heights ||=
        can_crop_vertically? ? MINIMUM_EDGE_CHARS..height - 1 : []
    end

    def can_crop_vertically?
      height > MINIMUM_EDGE_CHARS
    end

    def can_crop_horizontally?
      width > MINIMUM_EDGE_CHARS
    end
  end
end
