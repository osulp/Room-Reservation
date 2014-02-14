require 'spec_helper'

describe "logged in user changes" do
  context "when a user is not logged in" do
    before(:each) do
      # Stub out gatewaying
      RubyCAS::Filter.stub(:redirect_to_cas_for_authentication).and_return(true)
      visit root_path
    end
    it "should say you have to login to make a reservation" do
      expect(page).to have_content("Login to Reserve")
    end
    it "should let you click the link to login" do
      RubyCAS::Filter.should_receive(:redirect_to_cas_for_authentication).and_return(true)
      click_link("Login to Reserve")
    end
  end
  context "when a user is logged in" do
    before(:each) do
      RubyCAS::Filter.fake("fakeuser")
      visit root_path
    end
    it "should show a logout link" do
      within("#login-link") do
        expect(page).to have_content("Logout")
      end
    end
  end
end
