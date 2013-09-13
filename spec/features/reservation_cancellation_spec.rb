require 'spec_helper'

describe 'cancelling a reservation', :focus => true do
  include VisitWithAfterHook
  # TODO: Test this. Can't think of a good way to do it - The gateway filter would break things.
  let(:banner_record) {nil}
  context "when the user is logged in", :js => true do
    before(:all) do
      Timecop.return
    end
    before(:each) do
      RubyCAS::Filter.fake("fakeuser")
      create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
      banner_record
      @room = create(:room)
      @start_time = Time.current+1.hours
      @end_time = Time.current+2.hours
      create(:reservation, start_time: @start_time, end_time: @end_time, user_onid: "fakeuser", room: @room)
      visit root_path
      expect(page).to have_selector(".bar-info")
    end
    context "when the mouse is hovered over the user's reservation" do
      before(:each) do
        find(".bar-info").trigger(:mouseover)
      end
      it "should show the cancellation tooltip" do
        expect(page).to have_content("Click to Cancel")
      end
    end
    context "and the reservation isn't clicked" do
      it "should not show the cancellation popup" do
        expect(page).to have_selector("#cancel-popup", :visible => false)
      end
    end
    it_should_behave_like "a popup", ".bar-info", "#cancel-popup"
    describe "clicking cancel" do
      before(:each) do
        find(".bar-info").click
        click_link("Cancel")
      end
      it "should display a success message" do
        within("#cancel-popup") do
          expect(page).to have_content("This reservation has been cancelled!")
        end
      end
      it "should delete the reservation" do
        expect(page).to have_content("This reservation has been cancelled!")
        expect(Reservation.scoped.size).to eq 0
      end
      describe "then clicking to reserve again" do
        before(:each) do
          expect(page).to have_content("This reservation has been cancelled!")
          find(".bar-success").click
        end
        it "should hide the cancel popup" do
          expect(page).not_to have_selector("#cancel-popup")
        end
      end
    end
    context "when the reservation is clicked" do
      before(:each) do
        find(".bar-info").click
      end
      it "should ask if they want to cancel" do
        within("#cancel-popup") do
          expect(page).to have_content("Cancel")
        end
      end
      it "should display the room name" do
        within("#cancel-popup") do
          expect(page).to have_content(@room.name)
        end
      end
      it "should display the start time" do
        within("#cancel-popup") do
          expect(page).to have_content(@start_time.strftime("%l:%M %p"))
        end
      end
      it "should display the end time" do
        within("#cancel-popup") do
          expect(page).to have_content(@end_time.strftime("%l:%M %p"))
        end
      end
    end
  end
end
def after_visit(*args)
  page.execute_script("window.CalendarManager.truncate_to_now = function(){}") if example.metadata[:js]
  page.execute_script("window.CalendarManager.go_to_today()") if example.metadata[:js]
  expect(page).to have_selector("#loading-spinner") if example.metadata[:js]
  expect(page).not_to have_selector("#loading-spinner") if example.metadata[:js]
end