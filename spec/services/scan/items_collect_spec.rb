describe SpaceRadar::Services::Scan::ItemsCollect do
  let(:item) do
    SpaceRadar::Item.new(
      [
        'ooooooooo',
        'o--ooo--o',
        'oo-ooo-oo',
        'o--ooo--o',
        'ooooooooo'
      ]
    )
  end

  it 'does not pick cropped item derivates if scan position is not on the edge' do
    items = build_items_collect_result(item, 100, 50, 22, 13)
    expect(items.size).to eq(1)
    expect(items.first.width).to eq(9)
    expect(items.first.height).to eq(5)
  end

  context 'corner derivates' do
    it 'picks top left corner items' do
      items = build_items_collect_result(item, 100, 50, 0, 0)
      # base item + bottom right item crops
      # with combinations of:
      # - widths from 3 to 9
      # - heights from 3 to 5
      expect(items.size).to eq(21)
    end

    it 'picks top right corner items' do
      items = build_items_collect_result(item, 100, 50, 95, 0)
      # being on row 0 and having 5 columns to scan to the right
      # all bottom left item crops of width 5 should be selected: 5x3, 5x4, 5x5
      expect(items.size).to eq(3)
      expect(items.map { |i| "#{i.width}x#{i.height}" }.sort).to eq(
        ['5x3', '5x4', '5x5']
      )
    end

    it 'picks bottom right corner items' do
      items = build_items_collect_result(item, 100, 50, 95, 46)
      # 5 colums to the right edge and 4 rows to the bottom edge
      # picking a single item crop from its top left corner
      # having the dimensions 5x4
      expect(items.size).to eq(1)
      expect(items.first.width).to eq(5)
      expect(items.first.height).to eq(4)
    end

    it 'picks bottom left corner items' do
      items = build_items_collect_result(item, 100, 50, 0, 47)
      # being on column 0 and having 3 columns to scan downwards
      # all top right item crops of height 3 should be
      # selected: 3x3, 4x3, 5x3, 6x3, 7x3, 8x3, 9x3
      expect(items.size).to eq(7)
      expect(items.map { |i| "#{i.width}x#{i.height}" }.sort).to eq(
        ['3x3', '4x3', '5x3', '6x3', '7x3', '8x3', '9x3']
      )
    end
  end

  context 'edge derivates' do
    it 'picks top edge derivates' do
      items = build_items_collect_result(item, 100, 50, 25, 0)
      # base item + bottom side item crops of heights [3, 4]
      expect(items.size).to eq(3)
      expect(items.map { |i| "#{i.width}x#{i.height}" }.sort).to eq(
        ['9x3', '9x4', '9x5']
      )
    end

    it 'picks right edge derivates' do
      items = build_items_collect_result(item, 100, 50, 96, 20)
      # left side item crop of width 4
      expect(items.size).to eq(1)
      expect(items.first.width).to eq(4)
      expect(items.first.height).to eq(5)
    end

    it 'picks bottom edge derivates' do
      items = build_items_collect_result(item, 100, 50, 33, 46)
      # top side item crop of height 4
      expect(items.size).to eq(1)
      expect(items.first.width).to eq(9)
      expect(items.first.height).to eq(4)
    end

    it 'picks left edge derivates' do
      items = build_items_collect_result(item, 100, 50, 0, 10)
      # base item + right side item crops of widths from 3 to 8
      expect(items.size).to eq(7)
      expect(items.map { |i| "#{i.width}x#{i.height}" }.sort).to eq(
        ['3x5', '4x5', '5x5', '6x5', '7x5', '8x5', '9x5']
      )
    end
  end
end
