# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Sending Emails", type: :feature, js: true do
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

  describe 'Initial email sent' do
    it 'includes all items' do
      visit new_reserve_path(comp_key: 'AA-272C,123,456')

      page.find('#sw_url').set('12345')
      click_link 'add'
      page.find('#sw_url').set('54321')
      click_link 'add'

      expect do
        click_button 'Save and SEND request'
      end.to change { ActionMailer::Base.deliveries.count }.by(1)

      body = ActionMailer::Base.deliveries.last.body.to_s
      expect(body).to include('Title: Cats!')
      expect(body).to include('Title: Dogs!')
    end
  end

  describe 'Update emails sent' do
    context 'when an item is added' do
      it 'includes the data about the added item' do
        visit new_reserve_path(comp_key: 'AA-272C,123,456')

        page.find('#sw_url').set('12345')
        click_link 'add'

        click_button 'Save and SEND request'

        page.find('#sw_url').set('54321')
        click_link 'add'

        expect do
          click_button 'Save and SEND request'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)

        body = ActionMailer::Base.deliveries.last.body.to_s
        expect(body).to include('***ADDED ITEM***')
        expect(body).to include('Dogs!')
        expect(body).not_to include('Cats!') # Item sent in previous email
      end
    end

    context 'when an item is removed' do
      it 'includes the data about the removed item' do
        visit new_reserve_path(comp_key: 'AA-272C,123,456')

        page.find('#sw_url').set('12345')
        click_link 'add'
        page.find('#sw_url').set('54321')
        click_link 'add'

        click_button 'Save and SEND request'

        within(first('table tbody tr')) do
          click_link '[delete]'
        end

        expect do
          click_button 'Save and SEND request'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)

        body = ActionMailer::Base.deliveries.last.body.to_s

        expect(body).to include('***DELETED ITEM***')
        expect(body).to include('Cats!')
        expect(body).not_to include('Dogs!') # Item not deleted
      end
    end

    context 'when an item is edited' do
      it 'includes details about the updated item' do
        visit new_reserve_path(comp_key: 'AA-272C,123,456')

        page.find('#sw_url').set('12345')
        click_link 'add'
        page.find('#sw_url').set('54321')
        click_link 'add'

        click_button 'Save and SEND request'

        within(first('table tbody tr')) do
          fill_in 'Comments', with: 'My Added Comment'
        end

        page.find('body').click # force input blur

        expect do
          click_button 'Save and SEND request'
        end.to change { ActionMailer::Base.deliveries.count }.by(1)

        body = ActionMailer::Base.deliveries.last.body.to_s
        expect(body).to include('***EDITED ITEM***')
        expect(body).to include('Cats!')
        expect(body).not_to include('Dogs!') # Item not edited
      end
    end
  end
end
