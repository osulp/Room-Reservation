require 'spec_helper'

describe IntersessionHour do
  describe "#time_info" do
    describe "#time_info" do
      before(:each) do
        Timecop.freeze(Date.new(2013,8,19))
        @current_term = create(:intersession_hour)
      end
      context "when given a date with no results" do
        it "should return an empty hash" do
          IntersessionHour.time_info(Date.today-30.days).should == {}
        end
      end
      context "when given a monday inside the interval" do
        it "should return the start and end time for that day" do
          expect(IntersessionHour.time_info(Date.today)).to eq({Date.today => {'open' => "7:30 am", 'close' => "6:00 pm"}})
        end
        it "should return the same value for Monday->Friday" do
          4.times do |n|
            expect(IntersessionHour.time_info(Date.today+n.days)).to eq({Date.today+n.days => {'open' => "7:30 am", 'close' => "6:00 pm"}})
          end
        end
        it "should be able to return the time on sundays" do
          expect(IntersessionHour.time_info(Date.today+6.days)).to eq({Date.today+6.days => {'open' => '1:00 pm', 'close' => '6:00 pm'}})
        end
      end
    end
  end
end
