require 'spec_helper'

describe Reserver do
  before(:each) do
    Timecop.travel(Date.new(2013,8,29))
  end
  let(:user) {User.new("user")}
  let(:reserver) {User.new("user")}
  let(:room) {FactoryGirl.create(:room)}
  let(:start_time) {Time.current.midnight+12.hours}
  let(:end_time) {Time.current.midnight+14.hours+10.minutes}
  subject {Reserver.new(reserver, user, room, start_time, end_time)}
  describe "validations" do
    before(:each) do
      create(:special_hour, start_date: 60.days.ago, end_date: 60.days.from_now, open_time: '00:00:00', close_time: '00:00:00')
    end
    it {should validate_presence_of :start_time}
    it {should validate_presence_of :end_time}
    it {should validate_presence_of :room}
    it {should validate_presence_of :reserver}
    it {should validate_presence_of :reserved_for}
    it {should be_valid}
    context "when the duration is greater than what the user can have" do
      let(:end_time) {start_time + 4.hours}
      context "and the reserver is not an admin" do
        it "should be invalid" do
          expect(subject).not_to be_valid
        end
      end
      context "and the reserver is an admin" do
        before(:each) do
          create(:role, :role => "admin", :onid => reserver.onid)
        end
        it "should be valid" do
          expect(subject).to be_valid
        end
      end
    end
    context "when the reserver is not the same as the reserved_for" do
      let(:user) {User.new("user")}
      let(:reserver) {User.new("reserver")}
      context "and the reserver is an admin" do
        before(:each) do
          create(:role, :role => "admin", :onid => reserver.onid)
        end
        it "should be valid" do
          expect(subject).to be_valid
        end
      end
      context "and the reserver is not an admin" do
        it "should be invalid" do
          expect(subject).not_to be_valid
        end
      end
    end
    context "when the reservation starts in the past" do
      let(:start_time){ Time.current.midnight-4.hours }
      let(:end_time){ Time.current.midnight-2.hours }
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
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
    context "when there is another reservation for midnight the next day" do
      before(:each) do
        create(:reservation, start_time: Time.current.tomorrow.midnight, end_time: Time.current.tomorrow.midnight+2.hours, room: room, user_onid: user.onid)
      end
      context "and the reservation is for the current day" do
        let(:start_time) {Time.current.midnight+1.hours}
        let(:end_time) {Time.current.midnight+2.hours}
        context "and the max concurrency is set to 0" do
          before(:each) do
            APP_CONFIG["reservations"].stub(:[]).with("max_concurrent_reservations").and_return(0)
          end
          it "should be valid" do
            expect(subject).to be_valid
          end
        end
        # This test ensures that midnight of the next day is considered as "the next day"
        context "and the max concurrency is set to 1" do
          before(:each) do
            APP_CONFIG["reservations"].stub(:[]).with("max_concurrent_reservations").and_return(1)
          end
          it "should be valid" do
            expect(subject).to be_valid
          end
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
        expect(Reservation.all.size).to eq 1
      end
      it "should be idempotent" do
        subject.save
        expect(Reservation.all.size).to eq 1
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
  describe ".to_json" do
    before(:each) do
      subject.save
    end
    it "should delegate to reservation" do
      expect(subject.to_json).to eq subject.reservation.to_json
    end
  end
end
