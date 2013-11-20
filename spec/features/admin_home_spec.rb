require 'spec_helper'

describe "viewing the home page" do
  let(:user) {build(:user)}
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
    visit root_path
  end
  context "as an admin" do
    let(:user) {build(:user, :admin)}
    it "should have a link to the admin path" do
      expect(page).to have_link("(Admin)", :href => admin_path)
    end
  end
  context "as a user" do
    it "should not have a link to the admin path" do
      expect(page).not_to have_link("(Admin)", :href => admin_path)
    end
  end
end