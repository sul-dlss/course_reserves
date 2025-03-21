# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Sending Emails", :js do
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(
      CurrentUser.new('123', Settings.workgroups.superuser)
    )

    allow(SearchWorksItem).to receive(:new).with('12345').and_return(
      instance_double(SearchWorksItem, valid?: true, to_h: { ckey: '12345', title: 'Cats!' })
    )

    allow(SearchWorksItem).to receive(:new).with('54321').and_return(
      instance_double(SearchWorksItem, valid?: true, to_h: { ckey: '54321', title: 'Dogs!' })
    )
  end

  describe 'Initial email sent' do
    it 'includes all items' do
      visit new_reserve_path(comp_key: 'AA-272C,123,456')

      page.find_by_id('sw_url').set('12345')
      click_link 'add'
      page.find_by_id('sw_url').set('54321')
      click_link 'add'

      expect do
        click_button 'Save and SEND request'
        expect(page).to have_content 'Request sent'
      end.to change { ActionMailer::Base.deliveries.count }.by(1)

      body = ActionMailer::Base.deliveries.last.body.to_s
      expect(body).not_to include('*** ADDED ITEM ***')
      expect(body).to include(' 1. Cats!')
      expect(body).to include(' 2. Dogs!')
    end
  end

  describe 'Update emails sent' do
    context 'when an item is added' do
      it 'includes the data about the added item' do
        visit new_reserve_path(comp_key: 'AA-272C,123,456')

        page.find_by_id('sw_url').set('12345')
        click_link 'add'

        click_button 'Save and SEND request'

        page.find_by_id('sw_url').set('54321')
        click_link 'add'

        expect do
          click_button 'Save and SEND request'
          expect(page).to have_content 'Request sent'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)

        body = ActionMailer::Base.deliveries.last.body.to_s
        expect(body).to include('*** ADDED ITEM ***')
        expect(body).to include('Dogs!')
        expect(body).not_to include('Cats!') # Item sent in previous email
      end
    end

    context 'when an item is removed' do
      it 'includes the data about the removed item' do
        visit new_reserve_path(comp_key: 'AA-272C,123,456')

        page.find_by_id('sw_url').set('12345')
        click_link 'add'
        page.find_by_id('sw_url').set('54321')
        click_link 'add'

        click_button 'Save and SEND request'
        expect(page).to have_content 'Request sent'

        within(first('.reserve')) do
          click_link '[delete]'
        end

        expect do
          click_button 'Save and SEND request'
          expect(page).to have_content 'Request sent'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)

        body = ActionMailer::Base.deliveries.last.body.to_s

        expect(body).to include('***DELETED ITEM***')
        expect(body).to include('Cats!')
        expect(body).not_to include('Dogs!') # Item not deleted
      end
    end

    context 'when an item is edited' do
      # rubocop:disable RSpec/ExampleLength
      it 'includes details about the updated item' do
        visit new_reserve_path(comp_key: 'AA-272C,123,456')

        page.find_by_id('sw_url').set('12345')
        click_link 'add'
        page.find_by_id('sw_url').set('54321')
        click_link 'add'

        click_button 'Save and SEND request'
        expect(page).to have_content 'Request sent'

        within(first('.reserve')) do
          fill_in 'copies', with: 5
          select '1 day', from: 'Loan period'
          fill_in 'Comments', with: 'My Added Comment'
        end

        page.find('body').click # force input blur

        expect do
          click_button 'Save and SEND request'
          expect(page).to have_content 'Request sent'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)

        body = ActionMailer::Base.deliveries.last.body.to_s
        expect(body).to include('*** EDITED ITEM ***')
        expect(body).to include('Cats!')
        expect(body).to include('Print copies needed: 5 (WAS: 1)')
        expect(body).to include('Loan period: 1 day (WAS: 2 hours)')
        expect(body).not_to include('Dogs!') # Item not edited
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  describe 'Non-SearchWorks items' do
    it 'collects the title from the user' do
      visit new_reserve_path(comp_key: 'AA-272C,123,456')

      click_link "Reserve an item that's not in SearchWorks"
      expect(page).to have_content 'Course Reserves List Request'

      within(first('.reserve:not(#add_row)')) do
        expect(page).to have_css('textarea[name$="[title]"]', visible: true)
        fill_in 'Title', with: 'The title of an item that I would like'
      end

      expect do
        click_button 'Save and SEND request'
        expect(page).to have_content 'Request sent'
      end.to change { ActionMailer::Base.deliveries.count }.by(1)

      body = ActionMailer::Base.deliveries.last.body.to_s
      expect(body).to include('The title of an item that I would like')
    end
  end
end
