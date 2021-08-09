RSpec.shared_examples 'a scan result with properties' do |properties|
  it 'should match the expected properties' do
    expect(subject.size).to eq(1)

    found_result = subject.first
    expect(found_result[:x]).to eq(properties[:x])
    expect(found_result[:y]).to eq(properties[:y])
    expect(found_result[:match]).to eq(properties[:match])
    expect(found_result[:item].signature).to eq(properties[:signature])
  end
end
