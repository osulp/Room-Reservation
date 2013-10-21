require 'spec_helper'

describe Canceller do
  before(:each) do
    Timecop.travel(Time.current.midnight)
  end
  let(:user) {User.new("fakeuser")}
  let(:reservation) {create(:reservation, :user_onid => user.onid, start_time: Time.current+2.hours, end_time: Time.current+3.hours)}
  subject{Canceller.new(reservation, user)}
  describe "subject" do
    it "should be valid" do
      expect(subject).to be_valid
    end
  end
  describe "validations" do
    context "when the canceller is not an admin" do
      context "when the reservation isn't owned by the user" do
        let(:reservation) {create(:reservation, :user_onid => "bla", start_time: Time.current+2.hours, end_time: Time.current+3.hours)}
        it "should be invalid" do
          expect(subject).not_to be_valid
        end
      end
    end
    context "when the canceller is an admin" do
      # Implement with admin system
      before(:each) do
        create(:role, :role => "admin", :onid => "fakeuser")
      end
      context "when the reservation isn't owned by the user" do
        it "should be valid"
      end
    end
    context "when the reservation is in the past" do
      let(:reservation) {create(:reservation, :user_onid => user.onid, start_time: Time.current-4.hours, end_time: Time.current-2.hours)}
      it "should be invalid" do
        expect(subject).not_to be_valid
      end
    end
  end
  describe ".save" do
    context "when the canceller is invalid" do
      before(:each) do
        subject.stub(:valid?).and_return(false)
      end
      it "should return false" do
        expect(subject.save).to eq false
      end
    end
    context "when the canceller is valid" do
      before(:each) do
        subject.save
      end
      it "should return the deleted reservation" do
        expect(subject.save).not_to eq false
      end
      it "should delete the reservation" do
        expect(Reservation.all.size).to eq 0
      end
      it "should not REALLY delete the reservation" do
        expect(Reservation.find_by_sql("select * from reservations").length).to eq 1
        expect(Reservation.only_deleted.size).to eq 1
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
