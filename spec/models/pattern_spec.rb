describe SpaceRadar::Pattern do
  let(:pattern) do
    SpaceRadar::Pattern.new(
      [
        '-o-',
        'ooo',
        'o-o',
        '-o-'
      ]
    )
  end

  describe '#signature' do
    it 'is generates an empty signature by default' do
      expect(SpaceRadar::Pattern.new.signature).to eq([])
    end

    it 'returns the pattern signature' do
      expect(pattern.signature).to eq(
        [
          '-o-',
          'ooo',
          'o-o',
          '-o-'
        ]
      )
    end
  end

  describe '#signature_string' do
    it 'returns the pattern signature as a string' do
      expect(pattern.signature_string).to eq('-o-oooo-o-o-')
    end
  end

  describe '#width' do
    it 'returns the pattern signature width' do
      expect(pattern.width).to eq(3)
    end
  end

  describe '#height' do
    it 'returns the pattern signature height' do
      expect(pattern.height).to eq(4)
    end
  end

  describe '#match' do
    it 'calculates the similarity of the given patterns' do
      some_pattern = SpaceRadar::Pattern.new(
        [
          'oo-',
          'o-o',
          'ooo',
          '-oo'
        ]
      )
      other_pattern = SpaceRadar::Pattern.new(
        [
          '-oo-',
          'o-o-',
          '--oo'
        ]
      )

      expect(pattern.match(some_pattern)).to eq(66.67)
      expect(pattern.match(other_pattern)).to eq(58.33)
    end
  end
end
