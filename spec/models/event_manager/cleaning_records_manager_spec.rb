require 'spec_helper'

describe EventManager::CleaningRecordsManager do
  let(:room) {create(:room)}
  let(:start_time) {Time.current.midnight}
  let(:start_date) {Date.yesterday}
  let(:end_date) {Date.tomorrow}
  let(:end_time) {Time.current.tomorrow.midnight}
  subject{EventManager::CleaningRecordsManager.new(room)}

  describe "validations" do
    context "when there is no room" do
      let(:room) {nil}
      it {should_not be_valid}
    end
    context "when there is a room" do
      it {should be_valid}
    end
  end

  describe ".events_between" do
    before(:each) do
      Timecop.travel(Date.new(2013,8,22))
    end
    subject{EventManager::CleaningRecordsManager.new(room).events_between(start_time, end_time)}
    context "when there are no cleaning records for that room" do
      it "should return an empty array" do
        expect(subject).to eq []
      end
    end
    context "when there are cleaning records" do
      context "but they're out of range" do
        before(:each) do
          @cleaning = create(:cleaning_record, start_date: Date.yesterday, end_date: Date.yesterday)
          @cleaning.rooms << room
        end
        it "should return an empty array" do
          expect(subject).to eq []
        end
      end
      context "and the date range overlaps" do
        before(:each) do
          @cleaning = create(:cleaning_record, start_date: Date.yesterday, end_date: Date.tomorrow, start_time: Time.current.utc.yesterday.midnight, end_time: Time.current.utc.yesterday.midnight+4.hours)
          @cleaning.rooms << room
        end
        it "should return one event" do
          expect(subject.length).to eq 1
        end
        it "should set the events start and end time appropriately" do
          expect(subject.first.start_time).to eq Time.zone.parse("2013-08-22 00:00:00")
          expect(subject.first.end_time).to eq Time.zone.parse("2013-08-22 04:00:00")
        end
      end
    end
  end
end
