# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'reserves/_reserves_item.html.erb' do
  let(:item) { {} }
  let(:index) { 0 }

  before do
    render 'reserves/reserves_item', item: item, index: index
  end

  describe 'SearchWorks title' do
    let(:item) { { 'ckey' => '12345', 'title' => 'Cats!' } }

    it 'is linked to the SearchWorks record (in a new tab)' do
      expect(rendered).to have_css(
        'a[href="https://searchworks.stanford.edu/view/12345"][target="_blank"]',
        text: 'Cats!'
      )
    end
  end

  describe 'Imprint' do
    let(:item) { { 'ckey' => '12345', 'title' => 'Cats!', 'imprint' => '1st ed. - Mordor' } }

    it do
      expect(rendered).to have_css('p', text: '1st ed. - Mordo')
    end
  end

  context 'when an item is available online' do
    let(:item) { { 'ckey' => '12345', 'title' => 'Cats!', 'online' => true } }

    it 'renders text indicating the item is online' do
      expect(rendered).to have_css('p', text: 'Full text available online')
    end
  end
end
