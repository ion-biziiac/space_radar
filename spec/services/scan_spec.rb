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
        radar_scan: data_importer.radar_scan,
        known_items: data_importer.items
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
      expect(results.size).to eq(4)
      expect(results.map { |r| r[:match] }.sort).to eq([76.19, 78.57, 80.95, 90.48])
    end
  end

  context 'with scanning radar pattern edges and corners' do
    let(:item) do
      item_data = File.read('spec/fixtures/known_items/item.txt')
      SpaceRadar::Item.new(item_data.strip.split(/\n/))
    end

    context 'scan the top edge for partial items match' do
      let(:radar_scan) do
        SpaceRadar::Pattern.new(
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
      end
      subject { build_scan_result(radar_scan, [item]) }

      it_should_behave_like(
        'a scan result with properties',
        {
          x: 2,
          y: 0,
          match: 85.71,
          signature: [
            'oo---oo',
            'ooooooo',
            'oo-o-oo'
          ]
        }
      )
    end

    context 'scan the bottom edge for partial items match' do
      let(:radar_scan) do
        SpaceRadar::Pattern.new(
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
      end
      subject { build_scan_result(radar_scan, [item]) }

      it_should_behave_like(
        'a scan result with properties',
        {
          x: 5,
          y: 6,
          match: 82.14,
          signature: [
            '---o---',
            '--ooo--',
            'oo---oo',
            'oo---oo'
          ]
        }
      )
    end

    context 'scan the left edge for partial items match' do
      let(:radar_scan) do
        SpaceRadar::Pattern.new(
          [
            'o--o-o-o--o-',
            '-----o--o--o',
            'oo---o--o-o-',
            '-ooo--o----o',
            '--oo---o--o-',
            'o-oo-o---o--',
            'o-o-o----o-o',
            '--o-----o--o',
            'o---o----o--',
            '-o---o-o---o'
          ]
        )
      end
      subject { build_scan_result(radar_scan, [item]) }

      it_should_behave_like(
        'a scan result with properties',
        {
          x: 0,
          y: 1,
          match: 83.33,
          signature: [
            'o---',
            'oo--',
            '--oo',
            '--oo',
            'oooo',
            'o-oo'
          ]
        }
      )
    end

    context 'scan the right edge for partial items match' do
      let(:radar_scan) do
        SpaceRadar::Pattern.new(
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
      end
      subject { build_scan_result(radar_scan, [item]) }

      it_should_behave_like(
        'a scan result with properties',
        {
          x: 8,
          y: 3,
          match: 83.33,
          signature: [
            '---o',
            '--oo',
            'oo--',
            'oo--',
            'oooo',
            'oo-o'
          ]
        }
      )
    end

    context 'scan the top left corner for partial items match' do
      let(:radar_scan) do
        SpaceRadar::Pattern.new(
          [
            '---o---oo-o-',
            '--o--o-oo--o',
            'oo-o-o--o-o-',
            'o-oo--o-o---',
            '---o-------o',
            '-o---o--o---',
            '---o----o---',
            '--o-------o-',
            'o---o------o',
            '-o----o-----'
          ]
        )
      end
      subject { build_scan_result(radar_scan, [item]) }

      it_should_behave_like(
        'a scan result with properties',
        {
          x: 0,
          y: 0,
          match: 81.25,
          signature: [
            '--oo',
            '--oo',
            'oooo',
            'o-oo'
          ]
        }
      )
    end

    context 'scan the top right corner for partial items match' do
      let(:radar_scan) do
        SpaceRadar::Pattern.new(
          [
            'o--o---o-o--',
            '--o--o--oo--',
            'o--o-o--o-oo',
            'o--o-o--oo-o',
            '---o-------o',
            '-o---o--o---',
            '---o----o---',
            '--o-------o-',
            'o---o------o',
            '-o----o-----'
          ]
        )
      end
      subject { build_scan_result(radar_scan, [item]) }

      it_should_behave_like(
        'a scan result with properties',
        {
          x: 7,
          y: 0,
          match: 80.0,
          signature: [
            'oo---',
            'oo---',
            'ooooo',
            'oo-o-'
          ]
        }
      )
    end

    context 'scan the bottom right corner for partial items match' do
      let(:radar_scan) do
        SpaceRadar::Pattern.new(
          [
            'o--o---o-o--',
            '--o--o---o--',
            'o--o-o--o--o',
            'o--o-o---o-o',
            '---o-------o',
            '-o---o----o-',
            '---o------oo',
            '--o----o----',
            'o---o---o---',
            '-o----oo-ooo'
          ]
        )
      end
      subject { build_scan_result(radar_scan, [item]) }

      it_should_behave_like(
        'a scan result with properties',
        {
          x: 7,
          y: 5,
          match: 84.0,
          signature: [
            '---o-',
            '--ooo',
            'oo---',
            'oo---',
            'ooooo'
          ]
        }
      )
    end

    context 'scan the bottom left corner for partial items match' do
      let(:radar_scan) do
        SpaceRadar::Pattern.new(
          [
            'o--o---o-o--',
            '--o--o---o--',
            'o--o-o--o--o',
            'o--o-o---o-o',
            '---o-------o',
            '-o---o----o-',
            '-o--------o-',
            'o-o----o---o',
            '-o-o----o-o-',
            '---oo-o--o-o'
          ]
        )
      end
      subject { build_scan_result(radar_scan, [item]) }

      it_should_behave_like(
        'a scan result with properties',
        {
          x: 0,
          y: 6,
          match: 85.0,
          signature: [
            '-o---',
            'ooo--',
            '---oo',
            '---oo'
          ]
        }
      )
    end
  end
end
