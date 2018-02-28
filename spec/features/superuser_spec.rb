require 'rails_helper'

RSpec.describe "as a superuser", js: true do
  it "works" do
    page.driver.add_headers WEBAUTH_LDAPPRIVGROUP: "sulair:course-resv-admins"
    visit "/"
    click_on "Create a new reserve list"
    expect(page).to have_selector '.ui-dialog-title', text: "Select a course"
  end
end
