require 'spec_helper'

describe OverdueTruncator do
  let(:reservation) {create(:reservation, :start_time => start_time, :end_time => end_time)}
  let(:start_time) {Time.current-1.hour}
  let(:end_time) {Time.current+1.hour}
  let(:keycard) {nil}
  describe "#eligible_reservations" do
    subject {OverdueTruncator.new.send(:eligible_reservations)}
    before(:each) do
      reservation
      keycard
    end
    context "when there are ongoing reservations" do
      context "that have no keycard" do
        it "should return them" do
          expect(subject).to eq [reservation]
        end
        context "and have already been truncated" do
          before(:each) do
            reservation.truncated_at = Time.current
            reservation.save
          end
          it "should not return them" do
            expect(subject).to eq []
          end
        end
        context "which started before the limit" do
          before(:each) do
            OverdueTruncator.any_instance.stub(:truncate_limit).and_return(1.hour+1.minutes)
          end
          it "should not return them" do
            expect(subject).to eq []
          end
        end
      end
      context "that has a keycard" do
        let(:keycard) {create(:key_card, :reservation => reservation, :room => reservation.room)}
        it "should not return them" do
          expect(subject).to eq []
        end
      end
    end
    context "when there are reservations in the past" do
      let(:end_time) {Time.current-1.minute}
      it "should not return them" do
        expect(subject).to eq []
      end
    end
    context "when there are reservations in the future" do
      let(:start_time) {Time.current+10.minutes}
      it "should not return them" do
        expect(subject).to eq []
      end
    end
  end

  describe ".call" do
    let(:reservation_2) {create(:reservation, :start_time => start_time, :end_time => end_time)}
    let(:start_time_2) {Time.current-1.hour}
    let(:end_time_2) {Time.current+1.hour}
    subject {OverdueTruncator}
    context "when there are reservations to be truncated" do
      before(:each) do
        reservation
        reservation_2
      end
      it "should truncate all overdue reservations" do
        subject.call
        expect(reservation.reload.truncated_at).not_to be_blank
        expect(reservation_2.reload.truncated_at).not_to be_blank
      end
      it "should the change to days to be published once" do
        expect(CalendarPresenter).to receive(:publish_changed).exactly(1).times.with(start_time.to_date, end_time.to_date)
        subject.call
      end
    end
    context "when there are no reservations to be truncated" do
      it "should not error" do
        expect{subject.call}.not_to raise_error
      end
    end
  end
end