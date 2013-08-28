require 'spec_helper'

describe CleaningRecord do
  subject {build(:cleaning_record)}
  describe "validations" do
    it {should validate_presence_of(:start_date)}
    it {should validate_presence_of(:end_date)}
    it {should validate_presence_of(:start_time)}
    it {should validate_presence_of(:end_time)}
    it {should have_many(:cleaning_record_rooms)}
    it {should have_many(:rooms).through(:cleaning_record_rooms)}
    it "should require that the end date be greater than or equal to the start date" do
      subject.end_date = subject.start_date - 1.day
      expect(subject).not_to be_valid
    end
  end
  describe ".weekdays" do
    before(:each) do
      subject.weekdays = [1,2,3,4]
      subject.save
      subject.reload
    end
    it "should serialize" do
      expect(subject.weekdays).to eq [1,2,3,4]
    end
    it "should only accept an array" do
      subject.weekdays = {:bla => 1}
      expect(subject).not_to be_valid
    end
  end
end