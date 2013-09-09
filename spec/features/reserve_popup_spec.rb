require 'spec_helper'

describe 'reserve popup' do
  include VisitWithAfterHook
  # TODO: Test this. Can't think of a good way to do it - The gateway filter would break things.
  context "when the user isn't logged in" do
    it "shouldn't show a popup on click"
  end
  context "when the user is logged in", :js => true do
    before(:each) do
      RubyCAS::Filter.fake("fakeuser")
      create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
      create(:room)
      visit root_path
    end
    it "should hide the reservation popup" do
      expect(page).to have_selector("#reservation-popup", :visible => false)
    end
    context "when a green bar is clicked" do
      before(:each) do
        find(".bar-success").click
      end
      it "should show the reservation popup" do
        expect(page).to have_selector("#reservation-popup", :visible => true)
      end
      context "and they have no banner record" do
        it "should default to a 3 hour time range" do
          expect(page).to have_selector("#reservation-popup", :visible => true)
          within("#reservation-popup") do
            expect(find("#start-time")).to have_content("12:00 AM")
            expect(find("#end-time")).to have_content("3:00 AM")
          end
        end
      end
    end
  end
end
def after_visit(*args)
  page.execute_script("window.CalendarManager.truncate_to_now = function(){}") if example.metadata[:js]
  page.execute_script("window.CalendarManager.go_to_today()") if example.metadata[:js]
end