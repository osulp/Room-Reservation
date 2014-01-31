require 'spec_helper'

describe Reservation do
  describe "validations" do
     it {should validate_presence_of(:user_onid)}
     it {should validate_presence_of(:reserver_onid)}
     it {should validate_presence_of(:start_time)}
     it {should validate_presence_of(:end_time)}
     it {should validate_presence_of(:room)}
     it {should belong_to(:room)}
     it {should have_one(:key_card)}
  end
  describe ".ongoing" do
    subject {Reservation.ongoing}
    let(:reservation) {create(:reservation, :start_time => start_time, :end_time => end_time)}
    let(:start_time) {Time.current-1.hour}
    let(:end_time) {Time.current+1.hour}
    before(:each) do
      reservation
    end
    context "when there is a reservation ongoing" do
      it "should return it" do
        expect(subject).to eq [reservation]
      end
    end
    context "when the reservation is in the past" do
      let(:end_time) {Time.current-1.minute}
      it "should not return it" do
        expect(subject).to be_empty
      end
    end
    context "when the reservation is in the future" do
      let(:start_time) {Time.current+1.minute}
      it "should not return it" do
        expect(subject).to be_empty
      end
    end
  end
  describe ".active" do
    context "when there are reservations with key cards" do
      before(:each) do
        @reservation = create(:reservation)
        @key = create(:key_card, :reservation => @reservation, :room => @reservation.room)
      end
      it "should return all active reservations" do
        expect(Reservation.active).to eq [@reservation]
      end
    end
  end
  describe ".inactive" do
    context "when there are reservations with key cards" do
      before(:each) do
        @reservation = create(:reservation)
        @key = create(:key_card, :reservation => @reservation, :room => @reservation.room)
      end
      it "should return no reservations" do
        expect(Reservation.inactive).to eq []
      end
    end
    context "when there are reservations with no key cards" do
      before(:each) do
        @reservation = create(:reservation)
      end
      it "should return it" do
        expect(Reservation.inactive).to eq [@reservation]
      end
    end
    it "should be linkable with other scopes" do
      @reservation = create(:reservation,:start_time => Time.current-1.hour, :end_time => Time.current-30.minutes)
      @reservation_2 = create(:reservation, :start_time => Time.current-20.minutes, :end_time => Time.current+20.minutes)
      expect(Reservation.ongoing.inactive).to eq [@reservation_2]
    end
  end
end
