require 'rails_helper'

RSpec.describe Editor do
  it 'must have a sunetid' do
    expect(described_class.new(sunetid: '')).not_to be_valid
    expect(described_class.new(sunetid: 'something')).to be_valid
  end
end
