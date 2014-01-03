require 'spec_helper'

describe IpAddress do
  subject {build(:ip_address)}
  it {should validate_presence_of(:ip_address)}
  it {should validate_presence_of(:ip_address_i)}
  describe "validations" do
    it "should require a valid IP" do
      subject[:ip_address] = "bla"
      expect(subject).not_to be_valid
    end
  end
  describe ".ip_address=" do
    context "when given a valid IP" do
      before(:each) do
        subject.ip_address = "122.122.25.12"
      end
      it "should set ip_address_i" do
        expect(subject.ip_address_i).to eq IPAddr.new("122.122.25.12").to_i
      end
    end
    context "when given an invalid IP" do
      it "should not error" do
        expect{subject.ip_address = "bla"}.not_to raise_error
      end
    end
  end
end
