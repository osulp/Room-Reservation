require 'spec_helper'

describe Events::ReservationEvent do
  describe "marshalling" do
    context "when given a payload" do
      let(:reservation) {create(:reservation)}
      subject {Events::ReservationEvent.new(reservation.start_time, reservation.end_time, 0, reservation, reservation.room_id)}
      it "should not marshal the reservation object" do
        result = Marshal.dump(subject)
        expect(result.include?("updated")).to eq false
      end
      it "should reconstitute an appropriate object" do
        result = Marshal.load(Marshal.dump(subject))
        expect(result.payload.start_time).to eq subject.payload.start_time
        expect(result.payload.end_time).to eq subject.payload.end_time
      end

    end
  end
end
