require 'spec_helper'

describe AvailabilityChecker do
  let(:start_time) {Time.current.midnight+4.hours}
  let(:end_time) {Time.current.midnight+8.hours}
  let(:room) {create(:room)}
  subject{AvailabilityChecker.new(room, start_time, end_time)}
  before(:each) do
    Timecop.travel(Date.new(2013,8,29)) # A Thursday
  end
  describe ".available?" do
    context "when hours say it's open" do
      before(:each) do
        create(:special_hour, start_date: 30.days.ago.to_date, end_date: 30.days.from_now.to_date, open_time: "00:00:00", close_time: "00:00:00")
      end
      context "when there are no events" do
        it "should return true" do
          expect(subject).to be_available
        end
      end
      context "when the availability crosses midnight" do
        let(:start_time) {Time.current.midnight+22.hours}
        let(:end_time) {Time.current.midnight+26.hours}
        context "and the second day is closed" do
          before(:each) do
            room_hour = create(:room_hour, start_date: Date.tomorrow, end_date: Date.tomorrow, start_time: "04:00:00", end_time: "06:00:00")
            room_hour.rooms << room
          end
          it "should return false" do
            expect(subject).not_to be_available
          end
        end
        context "and there's a reservation that crosses midnight" do
          before(:each) do
            create(:reservation, start_time: Time.current.midnight+23.hours, end_time: Time.current.midnight+25.hours, room: room)
          end
          it "should return false" do
            expect(subject).not_to be_available
          end
        end
      end
      context "when there is a reservation" do
        context "for another room" do
          before(:each) do
            room_2 = create(:room)
            create(:reservation, start_time: Time.current.midnight+5.hours, end_time: Time.current.midnight+7.hours, room: room_2)
          end
          it "should return true" do
            expect(subject).to be_available
          end
        end
        context "in the middle of that time slot" do
          before(:each) do
            create(:reservation, start_time: Time.current.midnight+5.hours, end_time: Time.current.midnight+7.hours, room: room)
          end
          it "should return false" do
            expect(subject).not_to be_available
          end
        end
        context "which overlaps that time slot" do
          before(:each) do
            create(:reservation, start_time: Time.current.midnight+2.hours, end_time: Time.current.midnight+6.hours, room: room)
          end
          it "should return false" do
            expect(subject).not_to be_available
          end
        end
        context "ending on that time slot" do
          before(:each) do
            # Remove the ten minute buffer that gets added to reservations
            create(:reservation, start_time: Time.current.midnight, end_time: Time.current.midnight+4.hours-10.minutes, room: room)
          end
          it "should return true" do
            expect(subject).to be_available
          end
        end
        context "when starting at the end of the time slot" do
          before(:each) do
            create(:reservation, start_time: Time.current.midnight+8.hours+10.minutes, end_time: Time.current.midnight+10.hours, room: room)
          end
          it "should return true" do
            expect(subject).to be_available
          end
        end
        context "the exact duration of that time slot" do
          before(:each) do
            create(:reservation, start_time: Time.current.midnight+4.hours+10.minutes, end_time: Time.current.midnight+8.hours-10.minutes, room: room)
          end
          it "should return false" do
            expect(subject).not_to be_available
          end
        end
      end
    end
  end
end