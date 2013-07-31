require 'spec_helper'

describe CalendarPresenter do
  let(:fake_manager) {
    fake_manager = double("Fake Manager")
    fake_manager.stub(:events_between).and_return([event_1,event_2])
    return fake_manager
  }
  let(:event_1_start) {Time.current.midnight}
  let(:event_1_end) {Time.current.midnight+2.hours}
  let(:event_2_start) {Time.current.midnight+2.hours}
  let(:event_2_end) {Time.current.midnight+3.hours}
  let(:event_1_priority) {0}
  let(:event_2_priority) {0}
  let(:event_1) {Event.new(event_1_start, event_1_end,event_1_priority)}
  let(:event_2) { Event.new(event_2_start, event_2_end,event_2_priority)}
  let(:room) { create(:room) }
  subject {CalendarPresenter.new(room,Time.current.midnight, Time.current.tomorrow.midnight, fake_manager)}
  describe ".to_a" do
    context "when two events do not conflict" do
      it "should return the the events one after another with no truncation" do
        result = subject.to_a
        result.length.should == 2
        result[0].start_time.should == Time.current.midnight
        result[0].end_time.should == Time.current.midnight+2.hours
        result[1].start_time.should == Time.current.midnight+2.hours
        result[1].end_time.should == Time.current.midnight+3.hours
      end
    end
    context "when two events conflict" do
      context "and they have equal priority" do
        let(:event_2_start) {Time.current.midnight+1.hours}
        it "should truncate the later event" do
          result = subject.to_a
          result.first.should == event_1
          result.second.should == event_2
          result.second.start_time.should == Time.current.midnight+2.hours
        end
      end
      context "and they have different priorities" do
        let(:event_2_start) {Time.current.midnight+1.hours}
        let(:event_2_priority) {1}
        it "should truncate the first event (the lower priority one" do
          result = subject.to_a
          result.first.start_time.should == Time.current.midnight
          result.first.end_time.should == Time.current.midnight+1.hours
          result.second.start_time.should == Time.current.midnight+1.hours
          result.second.end_time.should == Time.current.midnight+3.hours
        end
      end
      context "and one completely overwrites another" do
        context "and they have different priorities" do
          let(:event_2_start) {Time.current.midnight}
          let(:event_2_priority) {1}
          it "should remove the lower priority event entirely" do
            result = subject.to_a
            result.length.should == 1
            result.first.start_time.should == Time.current.midnight
            result.first.end_time.should == Time.current.midnight+3.hours
          end
        end
      end
    end
  end
end
