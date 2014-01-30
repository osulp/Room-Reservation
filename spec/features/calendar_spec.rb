require 'spec_helper'

describe "calendar", :js => true do
  let(:user) {build(:user)}
  before(:each) do
    RubyCAS::Filter.fake(user.onid)
  end
  describe "cookie setting" do
    before(:each) do
      create(:special_hour, start_date: Date.yesterday, end_date: 60.days.from_now, open_time: "00:00:00", close_time: "00:00:00")
      create(:reservation, :start_time => Time.current.midnight+20.hours, :end_time => Time.current.midnight+22.hours)
      visit root_path
    end
    it "should go to the next day on click" do
      expect(page).to have_selector(".bar-danger")
      page.execute_script('$("*[data-handler=next]").click()')
      page.execute_script('$("a.ui-state-default:not(.ui-state-active)").first().click()')
      expect(page).not_to have_selector(".bar-danger")
    end
    it "should persist the clicked day" do
      expect(page).to have_selector(".bar-danger")
      page.execute_script('$("*[data-handler=next]").click()')
      page.execute_script('$("a.ui-state-default:not(.ui-state-active)").first().click()')
      expect(page).not_to have_selector(".bar-danger")
      visit root_path
      expect(page).not_to have_selector(".bar-danger")
    end
  end
  describe "navigation", :js => true do
    before(:each) do
      create(:room, :floor => 1)
      visit root_path
      expect(page).to have_selector('.bar-danger')
    end
    context "when the page is navigated to" do
      it "should redirect to the appropriate day link" do
        current_day = Time.current.to_date
        expect(current_path).to eq "/day/#{current_day.strftime("%Y-%m-%-d")}"
      end
      context "and a day is clicked" do
        before(:each) do
          all("*[data-handler=next]").first().click
          all("a.ui-state-default:not(.ui-state-active)").first().click
        end
        it "should go forward" do
          current_day = (Time.current+1.month).to_date
          current_day = Date.new(current_day.year, current_day.month, 1)
          expect(current_path).to eq "/day/#{current_day.strftime("%Y-%-m-%-d")}"
        end
        context "and then the back button is hit" do
          before(:each) do
            current_day = (Time.current+1.month).to_date
            current_day = Date.new(current_day.year, current_day.month, 1)
            expect(current_path).to eq "/day/#{current_day.strftime("%Y-%-m-%-d")}"
            page.evaluate_script('window.history.back()')
          end
          it "should go back" do
            current_day = Time.current.to_date
            expect(current_path).to eq "/day/#{current_day.strftime("%Y-%m-%-d")}"
          end
        end
      end
    end
  end
  describe "future days", :js => true do
    let(:day_limit) {1}
    before(:each) do
      Setting.stub(:day_limit).and_return(day_limit)
      visit root_path
      expect(page).to have_content(Time.current.strftime("%B"))
      @remaining_days = Time.days_in_month(Time.current.month) - Time.current.day + 1
    end
    context "when you are not an admin" do
      let(:day_limit) {0}
      context "and the day limit is 0" do
        it "should not restrict anything" do
          expect(page).to have_selector("a.ui-state-default", :count => @remaining_days)
        end
      end
      context "and the day limit is set" do
        let(:day_limit) {1}
        it "should hide future days past that point" do
          expect(page).to have_selector("a.ui-state-default", :count => 2)
        end
        context "when you hover" do
          let(:day_limit) {10}
          it "should show information" do
            if page.has_selector?('a[data-handler=next]')
              find('a[data-handler=next]').click
            end
            page.execute_script("$('span.ui-state-default').last().trigger('mouseenter')")
            expect(page).to have_selector(".tooltip")
          end
        end
        it "should not show information for past dates" do
          expect(page).to have_selector("a.ui-state-default", :count => 2)
          page.execute_script("$('span.ui-state-default').first().trigger('mouseenter')")
          expect(page).not_to have_selector(".tooltip")
        end
      end
    end
    context "when you are an admin" do
      let(:user) {build(:user, :staff)}
      context "and the day limit is set" do
        let(:day_limit) {1}
        it "should not hide anything" do
          expect(page).to have_selector("a.ui-state-default", :count => Time.days_in_month(Time.current.month))
        end
      end
    end
  end
  describe "past days" do
    before(:each) do
      visit root_path
      expect(page).to have_content(Time.current.strftime("%B"))
    end
    context "when you are not an admin" do
      it "should not let you go back in time", :js => true do
        expect(page).not_to have_selector("*[data-handler=prev]")
      end
      context "and you have a cookie set for a previous day" do
        before(:each) do
          create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
          create(:reservation, :start_time => Time.current.midnight+23.hours, :end_time => Time.current.midnight+24.hours)
          browser = page.driver
          browser.set_cookie('date', '2013-01-01')
          visit root_path
        end
        it "should move you to the current day" do
          expect(page).to have_selector('.bar-danger', :count => 1)
        end
      end
      context "and you have a cookie set for a past day" do
        before(:each) do
          create(:special_hour, start_date: 4.days.ago, end_date: 4.days.from_now, open_time: "00:00:00", close_time: "00:00:00")
          create(:reservation, :start_time => Time.current.midnight-2.days, :end_time => Time.current.midnight-2.days+1.hour)
          current_day = Time.current-2.days
          browser = page.driver
          browser.set_cookie('date', "#{current_day.year}-#{current_day.month}-#{current_day.day}")
          visit root_path
        end
        context "and you are not an admin" do
          it "should not show the past day" do
            expect(page).not_to have_selector(".bar-danger")
          end
        end
        context "and you are a staff member" do
          let(:user) {build(:user, :staff)}
          before(:each) do
            visit root_path
          end
          it "should show the past day" do
            expect(page).to have_selector(".bar-info")
          end
        end
      end
      context "and you have a cookie set for a future day" do
        before(:each) do
          create(:special_hour, start_date: 4.days.ago, end_date: 4.days.from_now, open_time: "00:00:00", close_time: "00:00:00")
          create(:reservation, :start_time => Time.current.midnight+2.days+23.hours, :end_time => Time.current.midnight+2.days+24.hours)
          current_day = Time.current+2.days
          visit root_path
          expect(page).to have_selector('button[data-handler="today"]')
          browser = page.driver
          browser.set_cookie('date', "#{current_day.year}-#{current_day.month}-#{current_day.day}", :path => '/')
          visit root_path
          visit root_path
        end
        it "should show the future day" do
          expect(page).to have_selector('button[data-handler="today"]')
          expect(page).to have_selector('.bar-danger', :count => 1)
        end
      end
    end
    context "when you are staff" do
      let(:user) {build(:user, :staff)}
      it "should let you go back in time", :js => true do
        expect(page).to have_selector("*[data-handler=prev]")
      end
    end
  end
end
