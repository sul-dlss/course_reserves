require 'rails_helper'

RSpec.describe 'Reserve Form', type: :feature do
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe '#edit' do
    let!(:reserve) do
      Reserve.create(
        cid: 'AA-272C',
        compound_key: 'AA-272C,123,456',
        item_list: [{'ckey' => '12345'}]
      )
    end

    context 'when the user is a superuser' do
      let(:user) { CurrentUser.new('superuser', Settings.workgroups.superuser) }

      it 'renders' do
        visit edit_reserve_path(reserve)

        expect(page).to have_css('h1', text: 'Course Reserves List Request')
        expect(page).to have_css('h2', text: /^AA-272C/)
      end
    end
  end
end
