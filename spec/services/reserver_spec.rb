require 'spec_helper'

describe Reserver do
  before(:each) do
    Timecop.travel(Date.new(2013,8,29))
  end
  let(:user) {User.new("user")}
  let(:reserver) {User.new("reserver")}
  let(:room) {FactoryGirl.create(:room)}
  let(:start_time) {Time.current.midnight+12.hours}
  let(:end_time) {Time.current.midnight+14.hours+10.minutes}
  subject {Reserver.new(reserver, user, room, start_time, end_time)}
  describe "validations" do
    before(:each) do
      create(:special_hour, start_date: 60.days.ago, end_date: 60.days.from_now, open_time: '00:00:00', close_time: '00:00:00')
    end
    context "when the given start time is greater than the end time" do
      let(:start_time) {end_time + 2.hours}
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
    context "when the start time is equal to the end time" do
      let(:start_time) {end_time}
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
    context "when the room is not persisted" do
      before(:each) do
        room.stub(:persisted?).and_return(false)
      end
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
    context "when the given timeframe is unavailable" do
      context "due to no hours" do
        before(:each) do
          Hours::SpecialHour.destroy_all
        end
        it "should be invalid" do
          expect(subject).not_to be_valid
        end
      end
      context "when another reservation exists already" do
        before(:each) do
          create(:reservation, start_time: Time.current.midnight+13.hours, end_time: Time.current.midnight+13.hours+10.minutes, room: room)
        end
        it "should be invalid" do
          expect(subject).not_to be_valid
        end
      end
    end
  end
  describe ".save" do
    context "when the model is invalid" do
      before(:each) do
        subject.stub(:valid?).and_return(false)
      end
      it "should return false" do
        expect(subject.save).to eq false
      end
    end
    context "when it's valid" do
      before(:each) do
        create(:special_hour, start_date: 60.days.ago, end_date: 60.days.from_now, open_time: '00:00:00', close_time: '00:00:00')
        subject.save
      end
      it "should create a new reservation" do
        expect(Reservation.scoped.size).to eq 1
      end
      it "should be idempotent" do
        subject.save
        expect(Reservation.scoped.size).to eq 1
      end
      describe "reservation" do
        before(:each) do
          @reservation = Reservation.first
        end
        it "should have the given time frame" do
          expect(@reservation.start_time).to eq start_time
          expect(@reservation.end_time).to eq end_time
        end
        it "should set the reserver onid" do
          expect(@reservation.reserver_onid).to eq reserver.onid
        end
        it "should set the user onid" do
          expect(@reservation.user_onid).to eq user.onid
        end
      end
    end
  end
end
