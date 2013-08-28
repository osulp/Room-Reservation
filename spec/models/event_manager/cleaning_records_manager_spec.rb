require 'spec_helper'

describe EventManager::CleaningRecordsManager do
  let(:room) {create(:room)}
  let(:start_time) {Time.current.midnight}
  let(:start_date) {Date.yesterday}
  let(:end_date) {Date.tomorrow}
  let(:end_time) {Time.current.tomorrow.midnight}
  subject{EventManager::CleaningRecordsManager.new}

  describe ".events_between" do
    before(:each) do
      Timecop.travel(Date.new(2013,8,22)) # Thursday
      @room = create(:room)
    end
    subject{EventManager::CleaningRecordsManager.new.events_between(start_time, end_time, [@room])}
    context "when there are no cleaning records for that room" do
      it "should return an empty array" do
        expect(subject).to eq []
      end
    end
    context "when there are cleaning records" do
      context "but they're out of range" do
        before(:each) do
          @cleaning = create(:cleaning_record, start_date: Date.yesterday, end_date: Date.yesterday)
          @cleaning.rooms << @room
        end
        it "should return an empty array" do
          expect(subject).to eq []
        end
      end
      context "and the date range overlaps" do
        before(:each) do
          @cleaning = create(:cleaning_record, start_date: Date.yesterday, end_date: Date.tomorrow, start_time: Time.current.utc.yesterday.midnight, end_time: Time.current.utc.yesterday.midnight+4.hours)
          @cleaning.rooms << @room
        end
        context "and the day of the week doesn't match" do
          before(:each) do
            @cleaning.weekdays = [1]
            @cleaning.save
          end
          it "should return no events" do
            expect(subject.length).to eq 0
          end
        end
        it "should return one event" do
          expect(subject.length).to eq 1
        end
        it "should set the events start and end time appropriately" do
          expect(subject.first.start_time).to eq Time.zone.parse("2013-08-22 00:00:00")
          expect(subject.first.end_time).to eq Time.zone.parse("2013-08-22 04:00:00")
        end
        it "should set the event's room id" do
          expect(subject.first.room_id).to eq @room.id
        end
        context "and the cleaning record applies to multiple rooms" do
          subject{EventManager::CleaningRecordsManager.new.events_between(start_time, end_time, [@room, @room_2])}
          before(:each) do
            @room_2 = create(:room)
            @cleaning.rooms << @room_2
          end
          it "should return one event per room" do
            expect(subject.length).to eq 2
          end
        end
      end
    end
  end
end