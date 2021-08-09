describe SpaceRadar::Services::ScreenDraw do
  let(:item1) do
    item_data = File.read('spec/fixtures/known_items/item.txt')
    SpaceRadar::Item.new(item_data.strip.split(/\n/))
  end
  let(:item2) do
    SpaceRadar::Item.new(['ooo', 'o-o', 'ooo'])
  end
  let(:results) do
    [
      { item: item1, x: 1, y: 0 },
      { item: item1, x: 17, y: 18 },
      { item: item2, x: 17, y: 3 },
      { item: item2, x: 8, y: 13 }
    ]
  end

  it 'draws the radar screen with the provided items' do
    service = SpaceRadar::Services::ScreenDraw.new(
      results: results,
      width: 25,
      height: 25
    )

    expected_output = <<~DATA
      ----o--------------------
      ---ooo-------------------
      -oo---oo-----------------
      -oo---oo---------ooo-----
      -ooooooo---------o-o-----
      -oo-o-oo---------ooo-----
      -------------------------
      -------------------------
      -------------------------
      -------------------------
      -------------------------
      -------------------------
      -------------------------
      --------ooo--------------
      --------o-o--------------
      --------ooo--------------
      -------------------------
      -------------------------
      --------------------o----
      -------------------ooo---
      -----------------oo---oo-
      -----------------oo---oo-
      -----------------ooooooo-
      -----------------oo-o-oo-
      -------------------------
    DATA

    expect($stdout).to receive(:puts).with("\033[0;32m")
    expect($stdout).to receive(:puts).with(expected_output.strip)
    service.run
  end
end
