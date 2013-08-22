require 'spec_helper'

describe "cleaning bars" do
  before(:each) do
    RubyCAS::Filter.fake("user")
    @room1 = create(:room)
    @special_hour = create(:special_hour, start_date: Date.yesterday, end_date: Date.tomorrow, open_time: "00:00:00", close_time: "00:00:00")
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
        @cleaning = create(:cleaning_record, start_date: Date.yesterday, end_date: Date.yesterday)
        @cleaning.rooms << @room1
        visit root_path
      end
      it "should not show any bars" do
        expect(page).not_to have_selector(".bar-danger")
      end
    end
    context "on that day" do
      before(:each) do
        @cleaning = create(:cleaning_record, start_date: Date.yesterday, end_date: Date.today)
        @cleaning.rooms << @room1
        @cleaning.save
        visit root_path
      end
      it "should show a bar" do
        expect(page).to have_selector(".bar-danger", :count => 1)
      end
      describe "caching", :caching => true do
        before(:each) do
          visit root_path
          expect(page).to have_selector(".bar-danger", :count => 1)
        end
        context "when a cleaning is deleted" do
          before(:each) do
            @cleaning.destroy
            visit root_path
          end
          it "should update the cache" do
            expect(page).not_to have_selector(".bar-danger")
          end
        end
        context "when a cleaning is changed to another day" do
          before(:each) do
            @cleaning.end_date = Date.yesterday
            @cleaning.save
            visit root_path

          end
          it "should update the cache" do
            expect(page).not_to have_selector(".bar-danger")
          end
        end
        context "when a cleaning is changed in the same day", :js => true do
          it "should update the cache" do
            @cleaning.end_time = @cleaning.end_time + 2.hours
            @cleaning.save
            current_height = page.evaluate_script("$('.bar-danger').first().height()")
            visit root_path
            new_height = page.evaluate_script("$('.bar-danger').first().height()")
            expect(current_height).not_to eq new_height
          end
        end
        context "when a new room is added" do
          before(:each) do
            @room2 = create(:room, :floor => 1)
            visit root_path
          end
          it "should update the cache" do
            expect(page).to have_selector(".room-data-bar", :count => 2)
          end
          context "then a new cleaning is added" do
            before(:each) do
              @cleaning = create(:cleaning_record, start_date: Date.today, end_date: Date.today)
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