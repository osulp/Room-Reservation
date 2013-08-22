require 'spec_helper'

describe Hours::Hour do
  describe "#time_info" do
    before(:each) do
      Timecop.travel(Date.new(2013,8,19))
      @current_term = create(:hour, open_time_1: "10:00 AM", close_time_1: "10:00 PM", open_time_7: "5:00 AM", close_time_7: "6:00 PM")
    end
    context "when given a date outside the term" do
      it "should return an empty hash" do
        Hours::Hour.time_info(Date.today-30.days).should == {}
      end
    end
    context "when given a monday inside the term" do
      it "should return the start and end time for that day" do
        expect(Hours::Hour.time_info(Date.today)).to eq({Date.today => {'open' => "10:00 am", 'close' => "10:00 pm"}})
      end
      it "should return the same value for Monday->Thursday" do
        3.times do |n|
          expect(Hours::Hour.time_info(Date.today+n.days)).to eq({Date.today+n.days => {'open' => "10:00 am", 'close' => "10:00 pm"}})
        end
      end
      it "should be able to return the time on sundays" do
        expect(Hours::Hour.time_info(Date.today+6.days)).to eq({Date.today+6.days => {'open' => '5:00 am', 'close' => '6:00 pm'}})
      end
    end
  end
end