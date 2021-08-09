describe SpaceRadar::Item do
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

  describe '#derivates' do
    it 'generates cropped derivates for all dimensions exceeding 3 characters' do
      expect(item.derivates[:top].map(&:signature)).to eq(
        [
          [
            'oo-ooo-oo',
            'o--ooo--o',
            'ooooooooo'
          ],
          [
            'o--ooo--o',
            'oo-ooo-oo',
            'o--ooo--o',
            'ooooooooo'
          ]
        ]
      )
      expect(item.derivates[:bottom].map(&:signature)).to eq(
        [
          [
            'ooooooooo',
            'o--ooo--o',
            'oo-ooo-oo'
          ],
          [
            'ooooooooo',
            'o--ooo--o',
            'oo-ooo-oo',
            'o--ooo--o'
          ]
        ]
      )
      expect(item.derivates[:top_left].first.signature).to eq(
        [
          '-oo',
          '--o',
          'ooo'
        ]
      )
      expect(item.derivates[:top_right].first.signature).to eq(
        [
          'oo-',
          'o--',
          'ooo'
        ]
      )
      expect(item.derivates[:right].first.signature).to eq(
        [
          'ooo',
          'o--',
          'oo-',
          'o--',
          'ooo'
        ]
      )
      expect(item.derivates[:bottom_right].last.signature).to eq(
        [
          'oooooooo',
          'o--ooo--',
          'oo-ooo-o',
          'o--ooo--'
        ]
      )
      expect(item.derivates[:bottom_left].last.signature).to eq(
        [
          'oooooooo',
          '--ooo--o',
          'o-ooo-oo',
          '--ooo--o'
        ]
      )
      expect(item.derivates[:left].last.signature).to eq(
        [
          'oooooooo',
          '--ooo--o',
          'o-ooo-oo',
          '--ooo--o',
          'oooooooo'
        ]
      )
    end

    it 'does not generate cropped derivates for dimensions up to 3 characters' do
      item = SpaceRadar::Item.new(
        [
          'ooo',
          'o-o',
          'ooo'
        ]
      )
      expect(item.derivates.values.map(&:empty?).uniq).to eq([true])
    end
  end
end
