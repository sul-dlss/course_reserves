require 'rails_helper'

RSpec.describe 'Reserve Form', type: :feature do
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  let(:reserve) do
    Reserve.create(
      cid: 'AA-272C',
      compound_key: 'AA-272C,123,456',
      item_list: [{'ckey' => '12345'}]
    )
  end

  describe '#new' do
    context 'when the user is a superuser' do
      let(:user) { CurrentUser.new('superuser', Settings.workgroups.superuser) }

      it 'renders' do
        visit new_reserve_path(comp_key: 'AA-272C,123,456')

        expect(page).to have_css('h1', text: 'Course Reserves List Request')
        expect(page).to have_css('h2', text: /^AA-272C/)
        expect(current_path).to eq '/reserves/new'
      end

      it 'redirects to the edit form of the most recently updated reserve if one exists' do
        reserve
        visit new_reserve_path(comp_key: 'AA-272C,123,456')
        expect(page).to have_css('h1', text: 'Course Reserves List Request')

        expect(current_path).to eq "/reserves/#{reserve.id}/edit"
      end
    end
  end

  describe '#edit' do
    before { reserve }

    context 'when the user is a superuser' do
      let(:user) { CurrentUser.new('superuser', Settings.workgroups.superuser) }

      it 'renders' do
        visit edit_reserve_path(reserve)

        expect(page).to have_css('h1', text: 'Course Reserves List Request')
        expect(page).to have_css('h2', text: /^AA-272C/)
      end
    end
  end

  describe '#clone' do
    before { reserve }

    context 'when the user is a superuser' do
      let(:user) { CurrentUser.new('superuser', Settings.workgroups.superuser) }

      context 'a reserve exists for the given term' do
        it 'does not clone the reserve and redirects to most recently updated reserve (with the same term)' do
          visit clone_reserve_path(reserve, term: reserve.term)

          expect(page).to have_css('.error', text: 'Course reserve list already exists for this course and term.')
          expect(current_path).to eq "/reserves/#{reserve.id}/edit"
        end
      end
    end
  end
end
