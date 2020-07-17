require 'rails_helper'

RSpec.describe Editor do
  it 'must have a sunetid' do
    expect(Editor.new(sunetid: '')).not_to be_valid
    expect(Editor.new(sunetid: 'something')).to be_valid
  end
end
