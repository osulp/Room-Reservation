require 'spec_helper'

describe EventManager::HoursManager do
  describe ".hours" do
    subject {EventManager::HoursManager.new}
    before(:each) do
      Timecop.freeze(Date.new(2013,8,19))
    end
    context "when there are just hours" do
      before(:each) do
        @hours = create(:hour)
      end
      it "should return the hours open and close time for that day" do
        expect(subject.hours(Date.today)).to eq( {"open" => "12:00 am", "close" => "12:00 am"} )
      end
    end
    context "when there are intersession hours" do
      before(:each) do
        @hours = create(:hour)
        @intersession_hours = create(:intersession_hour)
      end
      it "should prioritize the intersession hour times" do
        expect(subject.hours(Date.today)).to eq({"open" => "7:30 am", "close" => "6:00 pm"})
      end
    end
    context "when there are special hours" do
      before(:each) do
        @hours = create(:hour)
        @intersession_hours = create(:intersession_hour)
        @special_hours = create(:special_hour)
      end
      it "should prioritize the special hour times" do
        expect(subject.hours(Date.today)).to eq({"open" => "1:00 pm", "close" => "10:00 pm"})
      end
    end
  end
end