# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating Reserves', type: :feature, js: true do
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(
      CurrentUser.new('123', Settings.workgroups.superuser)
    )

    allow(SearchWorksItem).to receive(:new).with('12345').and_return(
      instance_double('SearchWorksItem', valid?: true, to_h: { ckey: '12345', title: 'Cats!' })
    )

    allow(SearchWorksItem).to receive(:new).with('54321').and_return(
      instance_double('SearchWorksItem', valid?: true, to_h: { ckey: '54321', title: 'Dogs!' })
    )
  end

  describe 'Save and Send Buttons' do
    it 'has the Send button disabled and enables when an item is added (disabled when removed)' do
      visit new_reserve_path(comp_key: 'AA-272C,123,456')

      expect(page).to have_button('Save draft', disabled: false)
      expect(page).to have_button('Save and SEND request', disabled: true)

      page.find('#sw_url').set('12345')
      click_link 'add'

      expect(page).to have_button('Save draft', disabled: false)
      expect(page).to have_button('Save and SEND request', disabled: false)

      within(first('table tbody tr')) do
        click_link '[delete]'
      end

      expect(page).to have_button('Save draft', disabled: false)
      expect(page).to have_button('Save and SEND request', disabled: true)
    end

    it 'persists items' do
      visit new_reserve_path(comp_key: 'AA-272C,123,456')

      page.find('#sw_url').set('12345')
      click_link 'add'
      page.find('#sw_url').set('54321')
      click_link 'add'

      click_button 'Save and SEND request'

      ckeys = Reserve.last.item_list.map { |item| item['ckey'] }
      expect(ckeys).to eq(%w[12345 54321])
    end
  end

  describe 'Adding/Removing Items' do
    it 'allows items to be added and removed' do
      visit new_reserve_path(comp_key: 'AA-272C,123,456')

      page.find('#sw_url').set('12345')
      click_link 'add'
      page.find('#sw_url').set('54321')
      click_link 'add'

      within('table#item_list_table tbody') do
        expect(page).to have_css('tr', count: 3)

        expect(page).to have_link('Cats!', href: 'https://searchworks.stanford.edu/view/12345')
        expect(page).to have_link('Dogs!', href: 'https://searchworks.stanford.edu/view/54321')

        within(first('tr')) do
          click_link '[delete]'
        end

        expect(page).to have_css('tr', count: 2)
        expect(page).not_to have_link('Cats!')
        expect(page).to have_link('Dogs!', href: 'https://searchworks.stanford.edu/view/54321')
      end
    end

    it 'does not allow the same item to be added twice' do
      visit new_reserve_path(comp_key: 'AA-272C,123,456')

      page.find('#sw_url').set('12345')
      click_link 'add'

      within('table#item_list_table tbody') do
        expect(page).to have_css('tr', count: 2)
        expect(page).to have_link(href: 'https://searchworks.stanford.edu/view/12345', count: 1)
      end

      page.find('#sw_url').set('12345')
      click_link 'add'

      within('table#item_list_table tbody') do
        expect(page).to have_css('tr', count: 2)
        expect(page).to have_link(href: 'https://searchworks.stanford.edu/view/12345', count: 1)
      end
    end
  end

  describe 'Digitization request inputs' do
    it 'the description field toggles disabled/enabled when digital_type changes' do
      visit new_reserve_path(comp_key: 'AA-272C,123,456')

      page.find('#sw_url').set('12345')
      click_link 'add'

      within('.digital-item-type') do
        expect(page).to have_css('input[type="radio"][name$="[digital_type]"][value="complete_work"][checked]')
        expect(page).to have_css('textarea[name$="[digital_type_description]"][disabled]')

        page.choose('chapter or article (up to 50 pages)')
        expect(page).to have_css('textarea[name$="[digital_type_description]"]')
        expect(page).not_to have_css('textarea[name$="[digital_type_description]"][disabled]')

        page.choose('complete work')
        expect(page).to have_css('input[type="radio"][name$="[digital_type]"][value="complete_work"][checked]')
        expect(page).to have_css('textarea[name$="[digital_type_description]"][disabled]')
      end
    end
  end
end