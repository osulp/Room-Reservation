require 'spec_helper'

describe Event do
  subject {build(:event)}
  describe "validations" do
    context "when start time is less than end time" do
      it {should be_valid}
    end
    context "when start time is greater than end time" do
      subject {build(:event, start_time: Time.current.tomorrow.midnight)}
      it {should_not be_valid}
    end
    context "when start time is equal to end time" do
      subject {build(:event, start_time: Time.current.midnight, end_time: Time.current.midnight)}
      it {should_not be_valid}
    end
  end

  describe "payload method access" do
    context "when there is no payload" do
      it "should raise on undefined methods" do
        expect{subject.blabla}.to raise_error
      end
    end
    context "when there is a payload" do
      let(:object) {
        o = double("object")
        o.stub(:blabla).and_return("bla")
        return o
      }
      subject{build(:event, object: object)}
      it "should raise on the payload's undefined method" do
        expect{subject.not_exist}.to raise_error
      end
      it "should delegate to payload if method doesn't exist" do
        expect(subject.blabla).to eq "bla"
      end
      it "should prefer the event's return value" do
        subject.stub(:blabla).and_return("monkey")
        expect(subject.blabla).to eq "monkey"
      end
      it "should be able to access the payload via .payload" do
        subject.stub(:blabla).and_return("monkey")
        expect(subject.payload.blabla).to eq "bla"
      end
    end
  end
end