require 'spec_helper'

describe Keycards::CheckinService do
  let(:keycard) {create(:key_card)}
  let(:user) {build(:user, :staff)}
  subject {Keycards::CheckinService.new(keycard, user)}
  it "should be valid" do
    expect(subject).to be_valid
  end
  context "when the user is not staff" do
    let(:user) {build(:user)}
    it "should be invalid" do
      expect(subject).not_to be_valid
    end
  end
  describe "#save" do
    before(:each) do
      @result = subject.save
    end
    context "when the key card has no reservation" do
      it "should return true" do
        expect(@result).to eq true
      end
    end
    context "when the keycard has a reservation" do
      before(:each) do
        Timecop.freeze
      end
      let(:keycard) {create(:key_card_checked_out, :reservation => reservation)}
      let(:reservation) {create(:reservation, :user_onid => user.onid, :reserver_onid => user.onid, :start_time => start_time, :end_time => end_time)}
      let(:start_time) {Time.current - 2.hours}
      let(:end_time) {Time.current + 2.hours}
      context "when the reservation is ongoing" do
        it "should return true" do
          expect(@result).to eq true
        end
        it "should truncate the reservation" do
          expect(Reservation.first.end_time).to eq Time.current
        end
      end
    end
  end
end