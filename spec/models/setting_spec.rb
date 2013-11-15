require 'spec_helper'

describe Setting do
  subject {Setting}
  after(:all) do
    Setting.druthers_cache.clear
  end
  describe "max_concurrent_reservations" do
    context "when it's set to a negative number" do
      it "should error" do
        expect{subject.max_concurrent_reservations = -1}.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
    context "when it's set to a string" do
      it "should error" do
        expect{subject.max_concurrent_reservations = "bla"}.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
    context "when it's set to a number" do
      it "should be fine" do
        expect{subject.max_concurrent_reservations = 2}.not_to raise_error
        expect(subject.max_concurrent_reservations).to eq 2
      end
    end
  end
  describe "announcement_header_message" do
    it "should always be success" do
      expect{subject.announcement_header_message = "bla"}.not_to raise_error
      expect(subject.announcement_header_message).to eq "bla"
    end
  end
end
