require 'rails_helper'

RSpec.describe "as a superuser", js: true do
  it "works" do
    allow_any_instance_of(ApplicationController).to receive(:remote_privgroups).and_return(['sulair:course-resv-admins'])
    visit "/"
    click_on "Create a new reserve list"
    expect(page).to have_selector '.modal-header', text: "Select a course"
  end
end
