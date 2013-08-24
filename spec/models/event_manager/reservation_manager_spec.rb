require 'spec_helper'

describe EventManager::ReservationManager do
  let(:room) {create(:room)}
  let(:start_time) {Time.current.midnight}
  let(:end_time) {Time.current.tomorrow.midnight}
  subject{EventManager::ReservationManager.new}
  describe ".events_between" do
    context "when there is no room" do
      let(:room) {nil}
      it "should raise an exception" do
        expect{subject.events_between(start_time,end_time, [room])}.not_to raise_error
      end
    end
    context "when there is a room" do
      subject {EventManager::ReservationManager.new.events_between(start_time, end_time, [room])}
      it "should not raise an exception" do
        expect{subject}.not_to raise_error
      end
      context "when the room has no reservations" do
        it "should return an empty array" do
          expect(subject).to eq []
        end
      end
      context "when the room has reservations for a previous day" do
        before(:each) do
          r = create(:reservation, :room => room, :start_time => start_time-5.hours, :end_time => start_time-4.hours)
        end
        it "should return an empty array" do
          expect(subject).to eq []
        end
      end
      context "when the room has reservations for a later day" do
        before(:each) do
          r = create(:reservation, :room => room, :start_time => Time.current.tomorrow.midnight+1.minute, :end_time => Time.current.tomorrow.midnight+2.hours)
        end
        it "should return an empty array" do
          expect(subject).to eq []
        end
      end
      context "when the room has a reservation with an end time within the slot" do
        before(:each) do
          @r = create(:reservation, :room => room, :start_time => Time.current.yesterday.midnight, :end_time => start_time + 2.hours)
        end
        it "should return that element" do
          expect(subject.length).to eq 1
        end
      end
      context "when the room has a reservation with a start time within the slot" do
        before(:each) do
         @r = create(:reservation, :room => room, :start_time => start_time, :end_time => Time.current.midnight + 3.days)
        end
        it "should return that element" do
          expect(subject.length).to eq 1
        end
        it "should return that element as an event" do
          expect(subject.first).to be_kind_of(Event)
        end
        it "pad the ends with a ten-minute padding" do
          event = subject.first
          expect(event.start_time).to eq @r.start_time-10.minutes
          expect(event.end_time).to eq @r.end_time+10.minutes
        end
        it "should set a priority of 0 on that event" do
          expect(subject.first.priority).to eq 0
        end
      end
      context "when the room has multiple reservations" do
        before(:each) do
          @r1 = create(:reservation, :room => room, :start_time => start_time + 6.hours, :end_time => end_time - 4.hours)
          @r2 = create(:reservation, :room => room, :start_time => start_time+5.hours, :end_time => end_time - 4.hours)
        end
        it "should sort by start_time" do
          expect(subject.first.payload).to eq @r2
          expect(subject.second.payload).to eq @r1
        end
      end
    end
  end
end
