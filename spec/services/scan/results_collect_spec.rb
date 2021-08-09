describe SpaceRadar::Services::Scan::ResultsCollect do
  let(:collector) { SpaceRadar::Services::Scan::ResultsCollect.new }
  let(:item1) do
    item_data = File.read('spec/fixtures/known_items/item.txt')
    SpaceRadar::Item.new(item_data.strip.split(/\n/))
  end
  let(:item2) do
    SpaceRadar::Item.new(['ooo', 'o-o', 'ooo'])
  end

  it 'collects results by storing the detected items' do
    collector.run(item1, 27, 32, 89.75)
    collector.run(item2, 78, 45, 98.10)

    expect(collector.results).to eq(
      [
        { item: item1, x: 27, y: 32, match: 89.75 },
        { item: item2, x: 78, y: 45, match: 98.10 }
      ]
    )
  end

  describe '#existing_result?' do
    it 'caches the positions of found results including their surface' do
      collector.run(item1, 27, 32, 89.75)

      expect(item1.width).to eq(7)
      expect(item1.height).to eq(6)
      expect(collector.existing_result?(0, 0)).to be_falsey
      expect(collector.existing_result?(27, 32)).to be_truthy
      expect(collector.existing_result?(34, 32)).to be_truthy
      expect(collector.existing_result?(35, 32)).to be_falsey
      expect(collector.existing_result?(29, 37)).to be_truthy
      expect(collector.existing_result?(34, 38)).to be_truthy
      expect(collector.existing_result?(35, 39)).to be_falsey
    end
  end
end
