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
    context "when the description has a swear word in it" do
      let(:reservation) {build(:reservation, :description => "shit dude")}
      it "should not be valid" do
        expect(reservation).not_to be_valid
      end
    end
    context "when the reservation has a key card" do
      let(:reservation) {build(:reservation)}
      let(:keycard) {create(:key_card, :room => reservation.room)}
      before(:each) do
        reservation.key_card = keycard
      end
      context "and it's an invalid keycard" do
        let(:keycard) {create(:key_card)}
        it "should be invalid" do
          expect(reservation).not_to be_valid
        end
      end
      context "and it's a valid keycard" do
        it "should be valid" do
          expect(reservation).to be_valid
        end
      end
    end
  end

  describe ".user_banner_record" do
    subject {create(:reservation, :user_onid => "bla")}
    context "when the user has no banner record" do
      it "should be null" do
        expect(subject.user_banner_record).to be_nil
      end
    end
    context "when the user has a banner record" do
      let(:banner_record) {create(:banner_record, :onid => subject.user_onid)}
      before(:each) do
        banner_record
      end
      it "should return the banner record" do
        expect(subject.user_banner_record).to eq banner_record
      end
    end
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

  describe 'versioning', :versioning => true do
    let(:reservation) {create(:reservation)}
    context "when a reservation is created" do
      it "should create an initial empty version" do
        expect(reservation.versions.size).to eq 1
      end
      it "should have an empty object in the first version" do
        expect(reservation.versions.first.object).to be_nil
      end
    end
    context "and then it's deleted" do
      before do
        reservation.destroy
      end
      it "should have two versions" do
        expect(reservation.versions.size).to eq 2
      end
      it "should create a version that was before the destruction" do
        expect(reservation.versions.last.reify.deleted_at).to be_nil
      end
    end
  end
end
