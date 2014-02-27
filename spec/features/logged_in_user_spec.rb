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

    context "they do not have a banner record" do
      it "should display username" do
        expect(page).to have_content("fakeuser")
      end
    end

    context "and they have a banner record" do
      before(:each)do
        create(:banner_record, :onid => "fakeuser", :fullName => "Sample Name" )
        visit root_path
      end
      it "should display the full name" do
        expect(page).to have_content("Sample Name")
      end
    end
  end
end

