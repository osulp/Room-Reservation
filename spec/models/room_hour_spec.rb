require 'spec_helper'

describe RoomHour do
  subject {build(:room_hour)}
  describe "validations" do
    it {should validate_presence_of :start_date}
    it {should validate_presence_of :end_date}
    it {should validate_presence_of :start_time}
    it {should validate_presence_of :end_time}
    it "should require that start_date is <= end date" do
      subject.start_date = Date.today
      subject.end_date = Date.today - 1.day
      expect(subject).not_to be_valid
    end
    it "should require that start_time is <= end_time" do
      subject.start_time = Time.current
      subject.end_time = Time.current - 2.hours
      expect(subject).not_to be_valid
    end
    it {should have_many(:room_hour_records)}
    it {should have_many(:rooms).through(:room_hour_records)}
  end
end
