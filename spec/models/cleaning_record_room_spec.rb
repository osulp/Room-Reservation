require 'spec_helper'

describe CleaningRecordRoom do
  describe "validations" do
    it {should belong_to(:room)}
    it {should belong_to(:cleaning_record)}
    it {should validate_presence_of(:room)}
    it {should validate_presence_of(:cleaning_record)}
    context "when a room has a cleaning record" do
      before(:each) do
        @room = create(:room)
        cleaning_record = create(:cleaning_record, start_date: Date.yesterday, end_date: Date.tomorrow)
        create(:cleaning_record_room, :room => @room, :cleaning_record => cleaning_record)
      end
      context "and the two conflict" do
        it "should be invalid" do
          new_cleaning_record = create(:cleaning_record, start_date: Date.today, end_date: Date.today)
          result = build(:cleaning_record_room, :room => @room, :cleaning_record => new_cleaning_record)
          expect(result).not_to be_valid
        end
      end
      context "and the two don't conflict" do
        it "should be valid" do
          new_cleaning_record = create(:cleaning_record, start_date: Date.today+2.days, end_date: Date.today+3.days)
          result = build(:cleaning_record_room, :room => @room, :cleaning_record => new_cleaning_record)
          expect(result).to be_valid
        end
      end
    end
  end
end
