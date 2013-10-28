require 'spec_helper'

describe CalendarPresenter do
  let(:fake_manager) {
    fake_manager = double("Fake Manager")
    fake_manager.stub(:events_between).and_return([all_events])
    return fake_manager
  }
  let(:all_events) {[event_1,event_2]}
  let(:event_1_start) {Time.current.midnight}
  let(:event_1_end) {Time.current.midnight+2.hours}
  let(:event_2_start) {Time.current.midnight+2.hours}
  let(:event_2_end) {Time.current.midnight+3.hours}
  let(:event_1_priority) {0}
  let(:event_2_priority) {0}
  let(:event_1) {Event.new(event_1_start, event_1_end,event_1_priority)}
  let(:event_2) { Event.new(event_2_start, event_2_end,event_2_priority)}
  subject {CalendarPresenter.new(Time.current.midnight, Time.current.tomorrow.midnight)}
  before(:each) do
    CalendarPresenter.stub(:managers).and_return([fake_manager])
  end
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
    context "when one event goes over the end time" do
      let(:event_2_end) {Time.current.tomorrow.midnight+3.hours}
      it "should truncate that event for viewing purposes" do
        result = subject.to_a
        result[1].end_time.should == Time.current.tomorrow.midnight
      end
    end
    context "when one event goes below the start time" do
      let(:event_1_start) {Time.current.midnight-3.hours}
      it "should truncate that event for viewing purposes" do
        result = subject.to_a
        result[0].start_time.should == Time.current.midnight
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
          context "and one of the events is for a different room" do
            let(:event_2) {Event.new(event_2_start, event_2_end, event_2_priority, nil, 5)}
            it "should not change that event" do
              result = subject.to_a
              result.length.should == 2
            end
          end
        end
      end
    end
    describe "room sorting" do
      context "when there are two events with two floors" do
        before(:each) do
          @room_1 = create(:room, :floor => 2)
          @room_2 = create(:room, :floor => 1)
        end
        it "should return the lowest floored room first" do
          expect(subject.rooms.first.object).to eq @room_2
        end
        it "should return floors in order" do
          expect(subject.floors.first).to eq 1
        end
      end
    end
    describe "complicated events" do
      let(:event_1) {Event.new(Time.current.midnight+1.hour+30.minutes,Time.current.midnight+2.hours+20.minutes,1)}
      let(:event_2) {Event.new(Time.current.midnight+2.hours, Time.current.midnight+4.hours+10.minutes,0)}
      let(:event_3) {Event.new(Time.current.midnight+3.hours, Time.current.midnight+8.hours,2)}
      let(:event_4) {Event.new(Time.current.midnight+6.hours, Time.current.midnight+7.hours+10.minutes, 3)}
      let(:event_5) {Event.new(Time.current.midnight+6.hours+30.minutes, Time.current.midnight+7.hours+10.minutes,2)}
      let(:event_6) {Event.new(Time.current.midnight+2.hours+50.minutes, Time.current.midnight+8.hours,2)} # Starts earlier than event_3 with same priority - eats it.
      let(:all_events) {[event_4, event_1, event_2, event_3, event_5, event_6]}
      it "should return as expected" do
        result = subject.to_a
        result.length.should == 4 # Event_5 eaten by event_4, event_3 eaten by event_6.
        m = Time.current.midnight
        # First result - no truncation
        result[0].start_time.should == m+1.hour+30.minutes
        result[0].end_time.should == m+2.hours+20.minutes
        # Second result - truncated on both sides
        result[1].start_time.should == m+2.hours+20.minutes # Truncated by event_6
        result[1].end_time.should == m+2.hours+50.minutes # Truncated by event_3
        # Third result - Truncated on end
        result[2].start_time.should == m+2.hours+50.minutes
        result[2].end_time.should == m+6.hours # Truncated by event_4
        # Fourth result - No truncation
        result[3].start_time.should == m+6.hours
        result[3].end_time.should == m+7.hours+10.minutes
      end
    end
  end
end