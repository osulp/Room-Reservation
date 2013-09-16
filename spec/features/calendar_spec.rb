require 'spec_helper'

describe "calendar", :js => true do
  describe "past days" do
    before(:each) do
      RubyCAS::Filter.fake("fakeuser")
      visit root_path
      expect(page).to have_content(Time.current.strftime("%B"))
    end
    context "when you are not an admin" do
      it "should not let you go back in time" do
        expect(page).not_to have_selector("*[data-handler=prev]")
      end
    end
    context "when you are an admin" do
      it "should let you go back in time"
    end
  end
end