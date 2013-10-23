require 'spec_helper'

describe "cleaning bars" do
  include VisitWithAfterHook
  before(:each) do
    RubyCAS::Filter.fake("user")
    @room1 = create(:room)
    @special_hour = create(:special_hour, start_date: Time.current.yesterday.to_date, end_date: Time.current.tomorrow.to_date, open_time: "00:00:00", close_time: "00:00:00")
  end
  context "when there are no cleanings" do
    before(:each) do
      visit root_path
    end
    it "should show no bars" do
      expect(page).not_to have_selector(".bar-danger")
    end
  end
  context "when there is a cleaning for that room" do
    context "on another day" do
      before(:each) do
        @cleaning = create(:cleaning_record, start_date: Time.current.yesterday.to_date, end_date: Time.current.yesterday.to_date)
        @cleaning.rooms << @room1
        visit root_path
      end
      it "should not show any bars" do
        expect(page).not_to have_selector(".bar-danger")
      end
    end
    context "on that day" do
      before(:each) do
        @cleaning = create(:cleaning_record, start_date: Time.current.yesterday.to_date, end_date: Time.current.to_date)
        @cleaning.rooms << @room1
        @cleaning.save
        visit root_path
      end
      context "but the cleaning is for a different weekday" do
        before(:each) do
          @cleaning.weekdays = [Time.current.yesterday.wday]
          @cleaning.save
          visit root_path
        end
        it "should not show any bars" do
          expect(page).not_to have_selector(".bar-danger")
        end
      end
      it "should show a bar" do
        expect(page).to have_selector(".bar-danger", :count => 1)
      end
      context "and there are multiple rooms that have that cleaning" do
        before(:each) do
          @room2 = create(:room)
          @cleaning.rooms << @room2
          visit root_path
        end
        it "should show two bars" do
          expect(page).to have_selector(".bar-danger", :count => 2)
        end
      end
      describe "caching", :caching => true do
        before(:each) do
          visit root_path
          expect(page).to have_selector(".bar-danger", :count => 1)
        end
        context "when a cleaning is deleted" do
          before(:each) do
            @cleaning2 = create(:cleaning_record, start_date: Time.current.yesterday.to_date, end_date: Time.current.to_date)
            @room2 = create(:room)
            @cleaning2.rooms << @room2
            @cleaning2.save
            visit root_path
            expect(page).to have_selector(".bar-danger", :count => 2)
            @cleaning.destroy
            visit root_path
          end
          it "should update the cache" do
            expect(page).to have_selector(".bar-danger", :count => 1)
          end
        end
        context "when a cleaning's weekdays are changed" do
          before(:each) do
            @cleaning.weekdays = [Time.current.yesterday.wday]
            @cleaning.save
            visit root_path
          end
          it "should update the cache" do
            expect(page).not_to have_selector(".bar-danger")
          end
        end
        context "when a cleaning is changed to another day" do
          before(:each) do
            @cleaning.end_date = Time.current.yesterday.to_date
            @cleaning.save
            visit root_path

          end
          it "should update the cache" do
            expect(page).not_to have_selector(".bar-danger")
          end
        end
        context "when a cleaning is changed in the same day", :js => true do
          before(:each) do
            visit root_path
            expect(page).to have_selector(".bar-danger")
          end
          it "should update the cache" do
            @cleaning.end_time = @cleaning.end_time + 2.hours
            @cleaning.save
            current_height = page.evaluate_script("$('.bar-danger').first().height()")
            visit root_path
            # Disable the truncation for testing.
            page.execute_script("window.CalendarManager.truncate_to_now = function(){}")
            new_height = page.evaluate_script("$('.bar-danger').first().height()")
            expect(current_height).not_to eq new_height
          end
        end
        context "when the applied room is removed" do
          before(:each) do
            @cleaning.rooms = []
            @cleaning.save
            visit root_path
          end
          it "should update the cache" do
            expect(page).not_to have_selector(".bar-danger")
          end
        end
        context "when a new room is added" do
          before(:each) do
            Timecop.travel(Time.current+2.seconds)
            @room2 = create(:room, :floor => 1)
            visit root_path
          end
          it "should update the cache" do
            expect(page).to have_selector(".room-data-bar", :count => 2)
          end
          context "then that room is is added to cleaning" do
            before(:each) do
              @cleaning.rooms << @room2
              visit root_path
            end
            it "should update the cache" do
              expect(page).to have_selector(".bar-danger", :count => 2)
            end
          end
          context "then a new cleaning is added" do
            before(:each) do
              @cleaning = create(:cleaning_record, start_date: Time.current.to_date, end_date: Time.current.to_date)
              @cleaning.rooms << @room2
              visit root_path
            end
            it "should update the cache" do
              expect(page).to have_selector(".bar-danger", :count => 2)
            end
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
