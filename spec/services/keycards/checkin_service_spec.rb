require 'spec_helper'

describe Keycards::CheckinService do
  let(:keycard) {create(:key_card)}
  let(:user) {build(:user, :staff)}
  subject {Keycards::CheckinService.new(keycard, user)}
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
      keycard.reservation.user_onid = ""
    end
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
      let(:keycard) {create(:key_card_checked_out, :reservation => reservation)}
      let(:reservation) {create(:reservation, :user_onid => user.onid, :reserver_onid => user.onid, :start_time => start_time, :end_time => end_time)}
      let(:start_time) {Time.current - 2.hours}
      let(:end_time) {Time.current + 2.hours}
      context "when the reservation is ongoing" do
        it "should return true" do
          expect(@result).to eq true
        end
        it "should truncate the reservation" do
          expect(Reservation.first.end_time.to_i).to eq Time.current.to_i
        end
      end
    end
  end
end