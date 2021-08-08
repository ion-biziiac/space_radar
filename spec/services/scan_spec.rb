require 'pry'
describe SpaceRadar::Services::Scan do
  context 'with scan accuracy' do
    let(:data_importer) do
      SpaceRadar::Services::DataImport.new(
        radar_scan_path: 'spec/fixtures/radar_scan_40_x_20.txt',
        known_items_dir_path: 'spec/fixtures/known_items'
      )
    end
    let(:scanner) do
      data_importer.run
      SpaceRadar::Services::Scan.new(
        data_importer.radar_scan,
        data_importer.items
      )
    end

    it 'finds the needed pattern when the accuracy is set to 90%' do
      scanner.accuracy = 90
      results = scanner.run
      expect(results.size).to eq(1)

      found_result = results.first
      expect(found_result[:x]).to eq(10)
      expect(found_result[:y]).to eq(4)
      expect(found_result[:match]).to eq(90.48)
    end

    it 'finds more matches when the accuracy is set to 75%' do
      scanner.accuracy = 75
      results = scanner.run
      expect(results.size).to eq(3)
      expect(results.map { |r| r[:match] }).to eq([80.95, 90.48, 78.57])
    end
  end

  context 'with scanning radar pattern edges' do
    let(:item) do
      radar_data = File.read('spec/fixtures/known_items/item.txt')
      SpaceRadar::Pattern.new(radar_data.strip.split(/\n/))
    end

    it 'scans the top edge for partial items match' do
      radar_scan = SpaceRadar::Pattern.new(
        [
          'o--o---oo-o-',
          'o-oo-oooo--o',
          '--oo-o--o-o-',
          '-o----o-o---',
          '---o-------o',
          '-o---o--o---',
          '---o----o---',
          '--o-------o-',
          'o---o------o',
          '-o----o-----'
        ]
      )
      scanner = SpaceRadar::Services::Scan.new(radar_scan, [item])
      results = scanner.run
      expect(results.size).to eq(1)

      found_result = results.first
      expect(found_result[:x]).to eq(2)
      expect(found_result[:y]).to eq(0)
      expect(found_result[:match]).to eq(85.71)
      expect(found_result[:item].signature).to eq(
        [
          'oo---oo',
          'ooooooo',
          'oo-o-oo'
        ]
      )
    end

    it 'scans the bottom edge for partial items match' do
      radar_scan = SpaceRadar::Pattern.new(
        [
          'o--o-o-o--o-',
          'o--o-o--o--o',
          'o--o-o--o-o-',
          '-o----o-o---',
          '---o---o---o',
          '-o---o--o---',
          '-oooo---o---',
          '--o---oooo--',
          'o---o-oo--o-',
          '-o---ooo---o'
        ]
      )
      scanner = SpaceRadar::Services::Scan.new(radar_scan, [item])
      results = scanner.run
      expect(results.size).to eq(1)

      found_result = results.first
      expect(found_result[:x]).to eq(5)
      expect(found_result[:y]).to eq(6)
      expect(found_result[:match]).to eq(82.14)
      expect(found_result[:item].signature).to eq(
        [
          '---o---',
          '--ooo--',
          'oo---oo',
          'oo---oo'
        ]
      )
    end

    it 'scans the left edge for partial items match' do
      radar_scan = SpaceRadar::Pattern.new(
        [
          'o--o-o-o--o-',
          '-----o--o--o',
          'oo---o--o-o-',
          '-ooo--o----o',
          '--oo---o--o-',
          'o-oo-o---o--',
          'o-o-oo---o-o-',
          '--o-----o--o',
          'o---o----o--',
          '-o---o-o---o'
        ]
      )
      scanner = SpaceRadar::Services::Scan.new(radar_scan, [item])
      results = scanner.run
      expect(results.size).to eq(1)

      found_result = results.first
      expect(found_result[:x]).to eq(0)
      expect(found_result[:y]).to eq(1)
      expect(found_result[:match]).to eq(83.33)
      expect(found_result[:item].signature).to eq(
        [
          'o---',
          'oo--',
          '--oo',
          '--oo',
          'oooo',
          'o-oo'
        ]
      )
    end

    it 'scans the right edge for partial items match' do
      radar_scan = SpaceRadar::Pattern.new(
        [
          'o--o-o-o--o-',
          'o--o-o--o--o',
          'o--o-o--o-o-',
          '-o----o----o',
          '---o---o--o-',
          '-o---o---o--',
          '-o--o---o---',
          '--o-----oo-o',
          'o---o--ooo-o',
          '-o---o-o---o'
        ]
      )
      scanner = SpaceRadar::Services::Scan.new(radar_scan, [item])
      results = scanner.run
      expect(results.size).to eq(1)

      found_result = results.first
      expect(found_result[:x]).to eq(8)
      expect(found_result[:y]).to eq(3)
      expect(found_result[:match]).to eq(83.33)
      expect(found_result[:item].signature).to eq(
        [
          '---o',
          '--oo',
          'oo--',
          'oo--',
          'oooo',
          'oo-o'
        ]
      )
    end
  end
end
