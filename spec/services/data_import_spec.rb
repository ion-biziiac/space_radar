describe SpaceRadar::Services::DataImport do
  it 'imports the default data files' do
    data_importer = SpaceRadar::Services::DataImport.new
    data_importer.run

    expect(data_importer.radar_scan).to be_a(SpaceRadar::Pattern)
    expect(data_importer.radar_scan.width).to eq(100)
    expect(data_importer.radar_scan.height).to eq(50)

    expect(data_importer.items.size).to eq(2)
    data_importer.items.each do |item|
      expect(item).to be_a(SpaceRadar::Pattern)
    end
  end

  it 'imports provided radar scan data file' do
    data_importer = SpaceRadar::Services::DataImport.new(
      radar_scan_path: 'spec/fixtures/radar_scan_40_x_20.txt'
    )
    data_importer.run

    expect(data_importer.radar_scan).to be_a(SpaceRadar::Pattern)
    expect(data_importer.radar_scan.width).to eq(40)
    expect(data_importer.radar_scan.height).to eq(20)
  end

  it 'imports provided known items files' do
    data_importer = SpaceRadar::Services::DataImport.new(
      known_items_dir_path: 'spec/fixtures/known_items'
    )
    data_importer.run

    expect(data_importer.items.size).to eq(1)
    item = data_importer.items.first
    expect(item).to be_a(SpaceRadar::Pattern)
    expect(item.width).to eq(7)
    expect(item.height).to eq(6)
  end

  it 'raises when the provided radar scan data file does not exist' do
    data_importer = SpaceRadar::Services::DataImport.new(
      radar_scan_path: 'does/not/exist.txt'
    )
    expect { data_importer.run }
      .to raise_error(
        ArgumentError,
        'Invalid radar_scan_path value: does/not/exist.txt'
      )
  end

  it 'raises when the provided known items files path does not exist' do
    data_importer = SpaceRadar::Services::DataImport.new(
      known_items_dir_path: 'does/not/exist'
    )
    expect { data_importer.run }
      .to raise_error(
        ArgumentError,
        'Invalid known_items_dir_path value: does/not/exist'
      )
  end

  it 'raises when the provided known items files path contains no *.txt files' do
    data_importer = SpaceRadar::Services::DataImport.new(
      known_items_dir_path: 'spec/fixtures/empty_folder'
    )
    expect { data_importer.run }
      .to raise_error(
        ArgumentError,
        'The path spec/fixtures/empty_folder contains no *.txt files'
      )
  end

  it 'raises when a provided data file is empty' do
    data_importer = SpaceRadar::Services::DataImport.new(
      radar_scan_path: 'spec/fixtures/empty.txt'
    )
    expect { data_importer.run }
      .to raise_error(
        ArgumentError,
        'One or more provided data files are empty'
      )
  end

  it 'raises when the radar scan pattern is smaller than at least one known item' do
    data_importer = SpaceRadar::Services::DataImport.new(
      radar_scan_path: 'spec/fixtures/radar_scan_10_x_5.txt',
      known_items_dir_path: 'spec/fixtures/known_items'
    )
    expect { data_importer.run }
      .to raise_error(
        ArgumentError,
        'One or more known items\' dimensions exceed the radar scan dimensions'
      )
  end
end
