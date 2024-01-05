require 'rails_helper'

RSpec.describe 'Copying a reserve list', js: true do
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(
      CurrentUser.new('123')
    )

    Reserve.create(
      cid: 'AA-272C',
      compound_key: 'AA-272C,123,456',
      term: Terms.current_term,
      has_been_sent: true,
      instructor_sunet_ids: '123,456'
    )
  end

  it 'allows a user to copy a course into a term' do
    visit '/'
    within '#main-container' do
      click_link 'Copy'
    end

    expect(page).to have_css('.clone-reserve-list', visible: true) # make sure modal renders
    within '#modal' do
      expect do
        click_link Terms.future_terms.first
      end.to change { Reserve.count }.by(1)
    end
  end

  it 'does not allow a user to create a reserve list for a term that one already exists for' do
    Reserve.create(
      cid: 'AA-272C',
      compound_key: 'AA-272C,123,456',
      term: Terms.future_terms.first,
      has_been_sent: true,
      instructor_sunet_ids: '123,456'
    )

    visit '/'

    within('#my-reserves tbody') do
      within(page.all('tr').last) do
        click_link 'Copy'
      end
    end

    expect(page).to have_css('.clone-reserve-list', visible: true) # make sure modal renders

    within '#modal' do
      expect(page).to have_no_css('a', text: /#{Terms.future_terms.first}/)
      expect(page).to have_content("#{Terms.future_terms.first} (reserve list already exists)")
      expect(page).to have_css('a', text: Terms.future_terms.last)
    end
  end

  it 'does not present a copy link for a reserve that has not been sent' do
    reserve = Reserve.last
    reserve.has_been_sent = false
    reserve.save

    visit '/'

    within(first('#my-reserves tbody tr')) do
      expect(page).to have_no_link('Copy')

      click_link 'Edit'
    end

    expect(page).to have_no_link 'Copy this list for a new quarter'
  end
end
