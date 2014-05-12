require 'spec_helper'

describe EventManager::HoursManager do
  describe ".hours" do
    subject {EventManager::HoursManager.new}
    before(:each) do
      Timecop.travel(Date.new(2013,8,19))
    end
    context "when there are just hours" do
      before(:each) do
        @hours = create(:hour)
      end
      it "should return the hours open and close time for that day" do
        expect(subject.hours(Date.today)["open"]).to eq "12:00 am"
        expect(subject.hours(Date.today)["close"]).to eq "12:00 am"
      end
    end
    context "when there are intersession hours" do
      before(:each) do
        @hours = create(:hour)
        @intersession_hours = create(:intersession_hour)
      end
      it "should prioritize the intersession hour times" do
        expect(subject.hours(Date.today)["open"]).to eq "7:30 am"
        expect(subject.hours(Date.today)["close"]).to eq "6:00 pm"
      end
    end
    context "when there are special hours" do
      before(:each) do
        @hours = create(:hour)
        @intersession_hours = create(:intersession_hour)
        @special_hours = create(:special_hour)
      end
      it "should prioritize the special hour times" do
        expect(subject.hours(Date.today)["open"]).to eq "1:00 pm"
        expect(subject.hours(Date.today)["close"]).to eq "10:00 pm"
      end
    end
  end

  describe ".events_between" do
    let(:hours_manager) {EventManager::HoursManager.new}
    subject {hours_manager.events_between(Time.current.midnight, Time.current.tomorrow.midnight, [@room])}
    before(:each) do
      @room = create(:room)
    end
    context "when the hours are 12:00 to 12:00" do
      before(:each) do
        Timecop.travel(Date.new(2013,8,19)) # A Monday
        @hours = create(:special_hour, open_time: "00:00:00", close_time: "00:00:00")
      end
      it "should return no events" do
        expect(subject).to eq []
      end
    end
    context "when there are room hours in addition to regular hours" do
      before(:each) do
        Timecop.travel(Date.new(2013,8,19)) # A Monday
        @hours = create(:special_hour, open_time: "00:00:00", close_time: "00:00:00")
        @room_hour = create(:room_hour, start_date: Date.today-1.day, end_date: Date.today+1.day, start_time: "12:00:00", end_time: "14:00:00")
        @room_hour.rooms << @room
      end
      it "should return events for the room hour" do
        expect(subject.length).to eq 2
        expect(subject.first.start_time).to eq Time.zone.parse("2013-08-19 00:00:00")
        expect(subject.first.end_time).to eq Time.zone.parse("2013-08-19 12:00:00")
        expect(subject.second.start_time).to eq Time.zone.parse("2013-08-19 13:50:00")
        expect(subject.second.end_time).to eq Time.zone.parse("2013-08-20 00:00:00")
      end
    end
    context "when no hours are returned" do
      it "should return one event that lasts the entire period for that day" do
        expect(subject.length).to eq 1
        expect(subject.first.start_time).to eq Time.current.midnight
        expect(subject.first.end_time).to eq Time.current.tomorrow.midnight
      end
    end
    context "when hours are 1:00 PM to 10:00 PM" do
      before(:each) do
        Timecop.travel(Date.new(2013,8,19)) # A Monday
        @hours = create(:special_hour, open_time: "13:00:00", close_time: "22:00:00")
      end
      it "should return two events" do
        expect(subject.length).to eq 2
      end
      it "should lock up the reservation from midnight to 1:00 PM" do
        expect(subject.first.start_time).to eq Time.current.midnight
        expect(subject.first.end_time).to eq Time.current.midnight+13.hours
      end
      it "should lock up the schedule from (22:00:00 - hour_buffer) to midnight" do
        expect(subject[1].start_time).to eq Time.current.midnight+22.hours-EventManager::EventManager::HourEventConverter.send(:hour_buffer)
        expect(subject[1].end_time).to eq Time.current.midnight+24.hours
      end
    end
    # 1:00 AM to 1:00 AM means "Closed"
    context "when hours are 1:00 AM to 1:00 AM" do
      before(:each) do
        Timecop.travel(Date.new(2013,8,19)) # A Monday
        @hours = create(:special_hour, open_time: "01:00:00", close_time: "01:00:00")
      end
      it "should return one event" do
        expect(subject.length).to eq 1
      end
      it "should close the schedule all day" do
        expect(subject.first.start_time).to eq Time.current.midnight
        expect(subject.first.end_time).to eq Time.current.tomorrow.midnight
      end
      context "and there are two rooms" do
        subject {EventManager::HoursManager.new.events_between(Time.current.midnight, Time.current.tomorrow.midnight, [@room, @room_2])}
        before(:each) do
          @room_2 = create(:room)
        end
        it "should return one event per room" do
          expect(subject.length).to eq 2
        end
      end
    end
    # 12:15 am to x means "Closes at x"
    context "when hours are 12:15 AM to 4:00 PM" do
      before(:each) do
        Timecop.travel(Date.new(2013,8,19)) # A Monday
        @hours = create(:special_hour, open_time: "00:15:00", close_time: "16:00:00")
      end
      it "should return one event" do
        expect(subject.length).to eq 1
      end
      it "should only lock the schedule from (4:00 - hour_buffer) to midnight" do
        expect(subject.first.start_time).to eq Time.current.midnight+16.hours-EventManager::EventManager::HourEventConverter.send(:hour_buffer)
        expect(subject.first.end_time).to eq Time.current.tomorrow.midnight
      end
    end
    # x to 12:15 AM means "x - no closing"
    context "when hours are 4:00 PM to 12:15 AM" do
      before(:each) do
        Timecop.travel(Date.new(2013,8,19)) # A Monday
        @hours = create(:special_hour, open_time: "16:00:00", close_time: "00:15:00")
      end
      it "should return one event" do
        expect(subject.length).to eq 1
      end
      it "should only lock the schedule from midnight to 4:00 PM" do
        expect(subject.first.start_time).to eq Time.current.midnight
        expect(subject.first.end_time).to eq Time.current.midnight+16.hours
      end
    end
  end
end
