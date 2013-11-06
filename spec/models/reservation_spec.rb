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
end
