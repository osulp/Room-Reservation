require 'spec_helper'

describe EventManager::HoursManager do
  describe ".hours" do
    subject {EventManager::HoursManager.new}
    before(:each) do
      Timecop.freeze(Date.new(2013,8,19))
    end
    context "when there are just hours" do
      before(:each) do
        @hours = create(:hour)
      end
      it "should return the hours open and close time for that day" do
        expect(subject.hours(Date.today)).to eq( {"open" => "12:00 am", "close" => "12:00 am"} )
      end
    end
    context "when there are intersession hours" do
      before(:each) do
        @hours = create(:hour)
        @intersession_hours = create(:intersession_hour)
      end
      it "should prioritize the intersession hour times" do
        expect(subject.hours(Date.today)).to eq({"open" => "7:30 am", "close" => "6:00 pm"})
      end
    end
    context "when there are special hours" do
      before(:each) do
        @hours = create(:hour)
        @intersession_hours = create(:intersession_hour)
        @special_hours = create(:special_hour)
      end
      it "should prioritize the special hour times" do
        expect(subject.hours(Date.today)).to eq({"open" => "1:00 pm", "close" => "10:00 pm"})
      end
    end
  end

  describe ".events_between" do
    subject {EventManager::HoursManager.new.events_between(Time.current.midnight, Time.current.tomorrow.midnight)}
    context "when the hours are 12:00 to 12:00" do
      before(:each) do
        Timecop.freeze(Date.new(2013,8,19)) # A Monday
        @hours = create(:special_hour, open_time: "00:00:00", close_time: "00:00:00")
      end
      it "should return no events" do
        expect(subject).to eq []
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
        Timecop.freeze(Date.new(2013,8,19)) # A Monday
        @hours = create(:special_hour, open_time: "13:00:00", close_time: "22:00:00")
      end
      it "should return two events" do
        expect(subject.length).to eq 2
      end
      it "should lock up the reservation from midnight to 1:00 PM" do
        expect(subject.first.start_time).to eq Time.current.midnight
        expect(subject.first.end_time).to eq Time.current.midnight+13.hours
      end
      it "should lock up the schedule from 22:00:00 to midnight" do
        expect(subject[1].start_time).to eq Time.current.midnight+22.hours
        expect(subject[1].end_time).to eq Time.current.midnight+24.hours
      end
    end
    # 1:00 AM to 1:00 AM means "Closed"
    context "when hours are 1:00 AM to 1:00 AM" do
      before(:each) do
        Timecop.freeze(Date.new(2013,8,19)) # A Monday
        @hours = create(:special_hour, open_time: "01:00:00", close_time: "01:00:00")
      end
      it "should return one event" do
        expect(subject.length).to eq 1
      end
      it "should close the schedule all day" do
        expect(subject.first.start_time).to eq Time.current.midnight
        expect(subject.first.end_time).to eq Time.current.tomorrow.midnight
      end
    end
    # 12:15 am to x means "Closes at x"
    context "when hours are 12:15 AM to 4:00 PM" do
      before(:each) do
        Timecop.freeze(Date.new(2013,8,19)) # A Monday
        @hours = create(:special_hour, open_time: "00:15:00", close_time: "16:00:00")
      end
      it "should return one event" do
        expect(subject.length).to eq 1
      end
      it "should only lock the schedule from 4:00 to midnight" do
        expect(subject.first.start_time).to eq Time.current.midnight+16.hours
        expect(subject.first.end_time).to eq Time.current.tomorrow.midnight
      end
    end
    # x to 12:15 AM means "x - no closing"
    context "when hours are 4:00 PM to 12:15 AM" do
      before(:each) do
        Timecop.freeze(Date.new(2013,8,19)) # A Monday
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