require 'spec_helper'

describe KeyCard do
  subject{build(:key_card)}
  describe "validations" do
    it {should validate_presence_of(:key)}
    it {should validate_presence_of(:room)}
    it {should validate_numericality_of(:key).only_integer}
    it {should belong_to(:reservation)}
    it {should belong_to(:room)}
    context "when the key card's room and the reservation's room aren't the same" do
      before(:each) do
        subject.reservation = build(:reservation)
      end
      it "should not be valid" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:reservation]).to include("is not for a room associated with this keycard.")
      end
    end
    context "when there is no reservation" do
      before(:each) do
        subject.reservation = nil
      end
      it "should be valid" do
        expect(subject).to be_valid
      end
    end
  end
end
