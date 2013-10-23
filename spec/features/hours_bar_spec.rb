require 'spec_helper'

describe "hour bars" do
  before(:each) do
    RubyCAS::Filter.fake("user")
    @room1 = create(:room, :floor => 1)
  end
  context "when there are no hours" do
    before(:each) do
      visit root_path
    end
    it "should lock everything down" do
      expect(page).to have_selector(".bar-danger", :count => 1)
    end
    context "and there are reservations" do
      before(:each) do
        create(:reservation, :start_time => Time.current.midnight, :end_time => Time.current.midnight+2.hours, :room => @room1)
        visit root_path
      end
      it "should only show one bar - the hours bar" do
        expect(page).to have_selector(".bar-danger", :count => 1)
      end
    end
  end
  context "when there are hours" do
    context "and the hours are room specific" do
      before(:each) do
        @room_hours = create(:room_hour, start_date: Time.current.to_date, end_date: Time.current.to_date, start_time: "04:00:00", end_time: "08:00:00")
        @room_hours.rooms << @room1
        visit root_path
      end
      it "should show the room specific hours" do
        expect(page).to have_selector(".bar-danger", :count => 2)
      end
      context "and there are two rooms" do
        before(:each) do
          Timecop.travel(Time.current+2.seconds)
          @room2 = create(:room, :floor => 1)
          visit root_path
        end
        it "should lock down the second room because it doesn't apply to the overall hours" do
          expect(page).to have_selector(".bar-danger", :count => 3)
        end
      end
    end
    context "and those hours aren't special" do
      before(:each) do
        create(:special_hour, open_time: "06:00:00", close_time: "14:00:00")
        visit root_path
      end
      it "should create two bars locking down available reservation times to those hours" do
        expect(page).to have_selector(".bar-danger", :count => 2)
      end
      context "and there are two rooms" do
        before(:each) do
          Timecop.travel(Time.current+2.seconds)
          @room2 = create(:room, :floor => 1)
          visit root_path
        end
        it "should show four bars - two for each room" do
          expect(page).to have_selector(".bar-danger", :count => 4)
        end
        context "and the second room has room specific hours" do
          before(:each) do
            @room_hours = create(:room_hour, start_date: Time.current.to_date, end_date: Time.current.to_date, start_time: "00:00:00", end_time: "00:00:00")
            @room_hours.rooms << @room2
            visit root_path
          end
          it "should show the room hours for that specific room" do
            expect(page).to have_selector(".bar-danger", :count => 2)
          end
          describe "caching", :caching => true do
            it "should act the same" do
              expect(page).to have_selector(".bar-danger", :count => 2)
            end
            context "when another room is added to the hours" do
              before(:each) do
                @room_hours.rooms << @room1
                visit root_path
              end
              it "should update the page" do
                expect(page).not_to have_selector(".bar-danger")
              end
            end
            context "when the room hours change" do
              before(:each) do
                @room_hours.start_time = "02:00:00"
                @room_hours.end_time = "03:00:00"
                @room_hours.save
                visit root_path
              end
              it "should update the page" do
                expect(page).to have_selector(".bar-danger", :count => 4)
              end
            end
          end
        end
      end
      context "and a reservation exists within that timeslot" do
        before(:each) do
          create(:reservation, :start_time => Time.current.midnight, :end_time => Time.current.midnight+2.hours, :room => @room1)
          visit root_path
        end
        it "should only display the hours" do
          expect(page).to have_selector(".bar-danger", :count => 2)
        end
      end
      context "and a reservation exists outside that timeslot" do
        before(:each) do
          create(:reservation, :start_time => Time.current.midnight+7.hours, :end_time => Time.current.midnight+9.hours, :room => @room1)
          visit root_path
        end
        it "should display both the hours and the reservation" do
          expect(page).to have_selector(".bar-danger", :count => 3)
        end
      end
    end
    context "and the hours lock the whole day down" do
      before(:each) do
        create(:special_hour, open_time: "01:00:00", close_time: "01:00:00")
        visit root_path
      end
      it "should only display one reservation bar" do
        expect(page).to have_selector(".bar-danger", :count => 1)
      end
    end
    context "and the hours only lock down after a certain point" do
      before(:each) do
        create(:special_hour, open_time: "00:15:00", close_time: "12:00:00")
        visit root_path
      end
      it "should only display one reservation bar" do
        expect(page).to have_selector(".bar-danger", :count => 1)
      end
    end
  end
  describe "caching", :caching => true do
    context "when hours change" do
      before(:each) do
        @hour = create(:special_hour, open_time: "00:15:00", close_time: "12:00:00")
        visit root_path
      end
      it "should change the number of bars if necessary" do
        expect(page).to have_selector(".bar-danger", :count => 1)
        @hour.open_time = "04:00:00"
        @hour.close_time = "08:00:00"
        @hour.save
        visit root_path
        expect(page).to have_selector(".bar-danger", :count => 2)
      end
    end
    context "when a reservation changes" do
      before(:each) do
        @hour = create(:special_hour, open_time: "00:15:00", close_time: "22:00:00")
        @r = create(:reservation, :start_time => Time.current.midnight, :end_time => Time.current.midnight+2.hours, :room => @room1)
        visit root_path
      end
      it "should update the cache" do
        expect(page).to have_selector(".bar-danger", :count => 2)
        @r.destroy
        visit root_path
        expect(page).to have_selector(".bar-danger", :count => 1)
      end
    end
    context "when there are room hours" do
      before(:each) do
        @hour = create(:room_hour, start_date: Time.current.yesterday.to_date, end_date: Time.current.tomorrow.to_date, start_time: "10:00:00", end_time: "12:00:00")
        @hour.rooms << @room1
        @hour2 = create(:room_hour, start_date: Time.current.yesterday.to_date, end_date: Time.current.tomorrow.to_date, start_time: "10:00:00", end_time: "12:00:00")
        @room2 = create(:room, :floor => 1)
        @hour2.rooms << @room2
        visit root_path
        expect(page).to have_selector(".bar-danger", :count => 4)
      end
      context "and a room hour is deleted" do
        before(:each) do
          @hour.destroy
          visit root_path
        end
        it "should update the cache" do
          expect(page).to have_selector(".bar-danger", :count => 3)
        end
      end
    end
  end
end
