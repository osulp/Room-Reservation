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
      context "and you have a cookie set for a previous day" do
        before(:each) do
          create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
          create(:reservation, :start_time => Time.current.midnight+23.hours, :end_time => Time.current.midnight+24.hours)
          browser = page.driver
          browser.set_cookie('day', '1')
          browser.set_cookie('month', '1')
          browser.set_cookie('year', '2012')
          visit root_path
        end
        it "should move you to the current day" do
          expect(page).to have_selector('.bar-danger', :count => 1)
        end
      end
      context "and you have a cookie set for a future day" do
        before(:each) do
          create(:special_hour, start_date: 4.days.ago, end_date: 4.days.from_now, open_time: "00:00:00", close_time: "00:00:00")
          create(:reservation, :start_time => Time.current.midnight+2.days+23.hours, :end_time => Time.current.midnight+2.days+24.hours)
          current_day = Time.current+2.days
          browser = page.driver
          browser.set_cookie('day', current_day.day.to_s)
          browser.set_cookie('month', current_day.month.to_s)
          browser.set_cookie('year', current_day.year.to_s)
          visit root_path
        end
        it "should show the future day" do
          expect(page).to have_selector('.bar-danger', :count => 1)
        end
      end
    end
    context "when you are an admin" do
      it "should let you go back in time"
    end
  end
end