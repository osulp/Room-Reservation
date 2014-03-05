require 'spec_helper'

describe Keycards::CheckoutService do
  let(:keycard) {create(:key_card, :room => reservation.room)}
  let(:user) {build(:user, :staff)}
  let(:reservation) {create(:reservation, :user_onid => user.onid, :reserver_onid => user.onid, :start_time => start_time, :end_time => end_time)}
  let(:start_time) {Time.current + 5.minutes}
  let(:end_time) {Time.current + 2.hours}
  subject {Keycards::CheckoutService.new(keycard, reservation, user)}
  before(:each) do
    Timecop.freeze
    create(:special_hour, start_date: 60.days.ago, end_date: 60.days.from_now, open_time: '00:00:00', close_time: '00:00:00')
  end
  it "should be valid" do
    expect(subject).to be_valid
  end
  context "when the user is not staff" do
    let(:user) {build(:user)}
    it "should be invalid" do
      expect(subject).not_to be_valid
    end
  end
  context "when the reservation is invalid" do
    let(:keycard) {create(:key_card_checked_out)}
    before(:each) do
      reservation.user_onid = ""
    end
    it "should be invalid" do
      expect(subject).not_to be_valid
    end
  end
  context "when the reservation is over" do
    let(:start_time) {Time.current - 2.hours}
    let(:end_time) {Time.current - 1.hours}
    it "should be invalid" do
      expect(subject).not_to be_valid
    end
  end
  context "when the reservation is checked out already" do
    let(:room) {create(:room)}
    let(:reservation) {create(:reservation, :user_onid => user.onid, :reserver_onid => user.onid, :start_time => start_time, :end_time => end_time, :key_card => create(:key_card, :room => room), :room => room)}
    it "should be invalid" do
      expect(subject).not_to be_valid
    end
  end
  context "when the key card is checked out already" do
    let(:keycard) {create(:key_card_checked_out)}
    it "should be invalid" do
      expect(subject).not_to be_valid
    end
  end
  context "when the key card is for a different room" do
    let(:keycard) {create(:key_card)}
    it "should be invalid" do
      expect(subject).not_to be_valid
    end
  end
  describe "#save" do
    before(:each) do
      @result = subject.save
    end
    context "when everything is valid" do
      let(:reservation) {create(:reservation, :user_onid => user.onid, :reserver_onid => user.onid, :start_time => start_time, :end_time => end_time)}
      let(:start_time) {Time.current + 5.minutes}
      let(:end_time) {Time.current + 2.hours}
      it "should return true" do
        expect(@result).to be_true
      end
      it "should attach the keycard to the reservation" do
        expect(KeyCard.first.reservation).to eq reservation
      end
    end
    context "when things are not valid" do
      let(:start_time) {Time.current - 2.hours}
      let(:end_time) {Time.current - 1.hours}
      it "should return false" do
        expect(@result).to be_false
      end
    end
  end
end
