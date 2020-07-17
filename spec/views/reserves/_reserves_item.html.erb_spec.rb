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

  context 'when an item is print only' do
    let(:item) { { 'ckey' => '12345', 'title' => 'Cats!' } }

    it 'renders form options to choose to digitize the whole/partial work' do
      expect(rendered).to have_css(
        'input[type="radio"][name$="[digital_type]"][value="complete_work"]'
      )
      expect(rendered).to have_css(
        'input[type="radio"][name$="[digital_type]"][value="partial_work"]'
      )
    end

    it 'renders a disabled text area to input chapter information for partial digitization requests' do
      expect(rendered).to have_css(
        'textarea[name$="[digital_type_description]"][disabled]'
      )
    end

    context 'when the digital type is partial' do
      let(:item) { { 'ckey' => '12345', 'title' => 'Cats!', 'digital_type' => 'partial_work' } }

      it 'renders a non-disabled text area to input chapter information for digitization requests' do
        expect(rendered).to have_css(
          'textarea[name$="[digital_type_description]"]'
        )
        expect(rendered).not_to have_css(
          'textarea[name$="[digital_type_description]"][disabled]'
        )
      end
    end
  end

  context 'when an item is available online' do
    let(:item) { { 'ckey' => '12345', 'title' => 'Cats!', 'online' => true } }

    it 'renders text indicating the item is online' do
      expect(rendered).to have_css('td', text: '✅ Full text available online')
    end

    it 'does not render form fields to request digitization' do
      expect(rendered).not_to have_css(
        'input[type="radio"][name$="[digital_type]"]'
      )

      expect(rendered).not_to have_css(
        'textarea[name$="[digital_type_description]"]'
      )
    end
  end

  context 'when an item is media' do
    let(:item) { { 'ckey' => '12345', 'title' => 'Cats!', 'media' => true } }

    it 'does not render the option to request a partial digitization of the work' do
      expect(rendered).to have_css(
        'input[type="radio"][name$="[digital_type]"][value="complete_work"]'
      )
      expect(rendered).not_to have_css(
        'input[type="radio"][name$="[digital_type]"][value="partial_work"]'
      )
    end
  end
end
