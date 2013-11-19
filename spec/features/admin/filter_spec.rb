require 'spec_helper'

describe "filter administration" do
  let(:user) {build(:user, :admin)}
  let(:filter) {create(:filter)}
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
    filter
    visit admin_filters_path
  end
  context "when there are filters defined" do
    it "should show them" do
      within(".admin-container") do
        expect(page).to have_content(filter.name)
      end
    end
    it "should let you edit a filter" do
      click_link "Edit"
      fill_in "filter_name", :with => "Near Restroom"
      click_button "Save"
      expect(page).to have_content("Room filter updated")
      expect(Filter.last.name).to eq "Near Restroom"
    end
    it "should let you delete a filter", :js => true do
      expect(page).to have_content(filter.name)
      find("a[href='/admin/filters/#{filter.id}'][data-method='delete']").click
      expect(page).not_to have_content(filter.name)
    end
  end
  it "should let you create a filter" do
    click_link "New Room Filter"
    fill_in "filter_name", :with => "Near Restroom"
    click_button "Create"
    expect(page).to have_content("Room filter added")
    expect(Filter.last.name).to eq "Near Restroom"
  end
end
